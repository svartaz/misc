const divMod = (x, y) => [math.floor(x / y), x % y];

const convert = (y, m, d) => {
  const date0 = Date.UTC(2000, 11, 21);
  const date = Date.UTC(y, m - 1, d);

  let milliseconds = date.getTime() - date0.getTime()
  let day = milliseconds / 1000 / 60 / 60 / 24;
  for (let year = 2000; ; y++) {
    (y != 0 && y % 128 == 0 ? 366 : 365)
  }

  return [year, yearday];
}
