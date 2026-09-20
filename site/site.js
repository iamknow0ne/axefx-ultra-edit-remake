'use strict';
const views = {
  editor: ['Signal grid with illustrated effect blocks and the Amp parameter inspector.', 'Move blocks. Draw connections. Dial in the details.'],
  library: ['The Ultra preset library, showing a search for slot 130 across all 384 slots.', 'All three banks. All 384 slots. Your sounds, accounted for.'],
  'bank-workspace': ['Numbered bank workspace with synthetic presets, slot actions and bank export.', 'Arrange a bank on your Mac before taking it to the rack.'],
  'cabinet-lab': ['Cabinet Lab with impulse response plots, blending and audio audition controls.', 'Prepare, blend and audition cabinet impulses locally.']
};
const picture = document.querySelector('#workspace-image');
const caption = document.querySelector('#view-caption');
const fullImage = document.querySelector('#full-image');
const buttons = [...document.querySelectorAll('[data-view]')];
buttons.forEach(button => button.addEventListener('click', () => {
  const key = button.dataset.view;
  if (!views[key]) return;
  picture.src = `images/${key}.png`;
  picture.alt = views[key][0];
  fullImage.href = picture.src;
  caption.textContent = views[key][1];
  buttons.forEach(item => item.setAttribute('aria-pressed', String(item === button)));
}));
