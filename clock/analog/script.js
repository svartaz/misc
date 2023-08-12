Math.TAU = 2 * Math.PI;
const nHands = 4;
const base = 16;

document.addEventListener("DOMContentLoaded", () => {
  const params = new URLSearchParams(window.location.search);

  const canvas = document.getElementsByTagName("canvas")[0];
  const context = canvas.getContext("2d");

  setInterval(() => {
    const w = context.canvas.width = context.canvas.height = Math.min(window.innerWidth, window.innerHeight);
    const r = w / 2;

    const line = (begin, end, angle) => {
      context.beginPath();
      context.moveTo(
        r + r * begin * Math.cos(- Math.TAU * (angle - 1 / 4)),
        r + r * begin * Math.sin(- Math.TAU * (angle - 1 / 4))
      );
      context.lineTo(
        r + r * end * Math.cos(- Math.TAU * (angle - 1 / 4)),
        r + r * end * Math.sin(- Math.TAU * (angle - 1 / 4))
      );
      context.stroke();
    }

    context.clearRect(0, 0, w, w);
    context.lineWidth = w / 128;
    context.imageSmoothingEnabled = true;

    const d = new Date();
    const day = (
      (d.getHours() * 60 + d.getMinutes()) * 60 + (d.getSeconds() + d.getMilliseconds() / 1000)
    ) / (24 * 60 * 60);

    for (let i = 0; i < base; i++)
      line(1 - 1 / (nHands + 2), 1 - 1 / (nHands + 2) / 2, i / base);

    for (let i = 0; i < nHands; i++)
      line(0, (nHands - i) / (nHands + 2), day * Math.pow(base, i) % 1);

  }, 1000 / base);
});
