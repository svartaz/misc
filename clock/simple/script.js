document.addEventListener("DOMContentLoaded", () => {
  const params = new URLSearchParams(window.location.search)
  const n = params.has("n") ? parseInt(params.get("n")) : 0;
  setInterval(() => {
    document.body.innerHTML = new Date().toISOString().slice(0, -(n + 1)) + "Z";
  });
});