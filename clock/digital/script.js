document.addEventListener("DOMContentLoaded", () => {
  setInterval(() => {
    const d = new Date();
    const year = d.getFullYear();
    const d0 = new Date(year, 0, 1);
    const day = (d.getTime() - d0.getTime()) / (1000 * 60 * 60 * 24);

    document.getElementsByTagName("div")[0].innerHTML = `${year + 10000}/${day.toString()
      .replace(/^(\d\d\.)/, "0$1")
      .replace(/$/, "00000")
      .replace(/(\.\d\d\d\d\d).+/, "$1")
      }`;
  });
});
