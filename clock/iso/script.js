document.addEventListener("DOMContentLoaded", () => {
  setInterval(() => {
    document.body.innerHTML =
      new Date().toISOString().replace(/\d(?=Z)/, '');
  });
});