#include <cmath>
#include <fstream>
#include <iostream>
#include <filesystem>
#include <vector>
#include "NAM/get_dsp.h"

// Central finite difference about silence, after identical warm-up. This is
// a local linearization, not an amplifier conversion or a best linear fit.
std::vector<double> response(const std::filesystem::path& path, double amplitude, double rate, int count) {
    auto dsp = nam::get_dsp(path);
    if (!dsp || dsp->NumInputChannels()!=1 || dsp->NumOutputChannels()!=1)
        throw std::runtime_error("Only mono-input, mono-output NAM models are supported.");
    dsp->ResetAndPrewarm(rate, 64);
    std::vector<double> result(count);
    NAM_SAMPLE input[64]{}, output[64]{};
    NAM_SAMPLE* inputs[] = {input}; NAM_SAMPLE* outputs[] = {output};
    for (int start=0;start<count;start+=64) {
        std::fill(input,input+64,0.0); if (start==0) input[0]=amplitude;
        int n=std::min(64,count-start); dsp->process(inputs,outputs,n);
        for(int i=0;i<n;++i) {
            if (!std::isfinite(output[i])) throw std::runtime_error("Model produced non-finite audio.");
            result[start+i]=output[i];
        }
    }
    return result;
}
int main(int argc,char** argv) {
    try {
        if(argc!=3) throw std::runtime_error("Usage: nam-ir model.nam output.json");
        const std::filesystem::path path(argv[1]);
        if (std::filesystem::file_size(path)>64*1024*1024) throw std::runtime_error("NAM file exceeds the 64 MB limit.");
        auto dsp=nam::get_dsp(path);
        double rate=dsp->GetExpectedSampleRate();
        if (!(rate>=8000 && rate<=192000)) throw std::runtime_error("NAM must declare a sample rate between 8 and 192 kHz.");
        dsp.reset();
        int n=static_cast<int>(std::ceil(rate*0.1));
        auto pos=response(path,0.01,rate,n), neg=response(path,-0.01,rate,n);
        auto largePos=response(path,0.1,rate,n), largeNeg=response(path,-0.1,rate,n);
        double energy=0,error=0;
        for(int i=0;i<n;i++) {
            pos[i]=(pos[i]-neg[i])/0.02;
            double large=(largePos[i]-largeNeg[i])/0.2;
            energy+=pos[i]*pos[i]; error+=(large-pos[i])*(large-pos[i]);
        }
        if (!std::isfinite(energy) || energy<1e-14) throw std::runtime_error("No usable small-signal response; this model cannot be approximated by this method.");
        nlohmann::json report={{"sampleRate",rate},{"samples",pos},
            {"levelSensitivityPercent",100*std::sqrt(error/energy)},
            {"method","Central finite difference at silence, +/-0.01 FS; comparison +/-0.1 FS; 100 ms"},
            {"limitation","Linear approximation only. No distortion, compression, dynamics, or guarantee of perceptual similarity."}};
        std::ofstream stream(argv[2]); if(!stream) throw std::runtime_error("Cannot create result.");
        stream << report.dump(); if(!stream) throw std::runtime_error("Cannot write result.");
        return 0;
    } catch(const std::exception& e) { std::cerr << e.what() << '\n'; return 1; }
}
