document.addEventListener("DOMContentLoaded", () => {
  setInterval(() => {
    const d = new Date();
    const year = d.getFullYear();
    const d0 = new Date(year, 0, 1);
    const millisec = d.getTime() - d0.getTime();
    const millisecPerDay = 1000 * 60 * 60 * 24;
    const day = millisec / millisecPerDay;

    document.body.querySelector('div').innerHTML =
      d.toISOString()
        .replace(/\d\d-\d\d(?=T)/, Math.floor(day))
        .replace(/\d(?=Z)/, '');
  });
});