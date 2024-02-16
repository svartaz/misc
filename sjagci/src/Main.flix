mod Matrix {
    pub def update(i: Int32, j: Int32, v: a, m: Vector[Vector[a]]): Option[Vector[Vector[a]]] =
        forM(vector <- Vector.nth(i, m))
            yield m |> Vector.update(i, vector |> Vector.update(j, v))

    pub def get(i: Int32, j: Int32, m: Vector[Vector[a]]): Option[a] =
        forM(
            vector <- Vector.nth(i, m);
            a <- Vector.nth(j, vector)
        )
            yield a
}

mod List {
    pub def headTail(l: List[a]): Option[(a, List[a])] =
        match l {
            case head :: tail => (Some(head, tail))
            case Nil => None
        }

    pub def pop(n: Int32, l: List[a]): Option[(a, List[a])] = {
        def f(i: Int32, left: List[a], right: List[a]) = match right {
            case (head :: tail) =>
                if(i == n)
                    Some((head, left ::: tail))
                else
                    f(i + 1, left ::: List#{head}, tail)
            case Nil => None
        };

        f(0, Nil, l)
    }
}

enum Kind with Eq, Order{
    case Pawn,
    case Lance,
    case Knight,
    case Silver,
    case Gold,
    case Bishop,
    case Rook,
    case King
}

instance ToString[Kind] {
    pub def toString(k: Kind): String =
        match k {
            case Kind.Pawn => "p"
            case Kind.Lance => "l"
            case Kind.Knight => "n"
            case Kind.Silver => "s"
            case Kind.Gold => "g"
            case Kind.Bishop => "b"
            case Kind.Rook => "r"
            case Kind.King => "k"
        }
}

type alias Square =
    Option[{
        kind = Kind,
        first = Bool,
        promoted = Bool
    }]

type alias Board =
    Vector[Vector[Square]]

def printGame(board: Board, captures0: List[Kind], captures1: List[Kind]): Unit \ IO =
    board
    |> Vector.mapWithIndex(y -> row ->
        row
        |> Vector.map(square -> match square {
            case None => "."
            case Some(p) =>
                ToString.toString(p.kind)
                |> (if(p.promoted) String.toUpperCase else identity)
                |> if(p.first) Console.cyan else Console.magenta
        })
        |> (it -> Vector.append(Vector#{ToString.toString(y)}, it))
        |> Vector.join(" ")
        |> it -> it +
            if(y == 0) " " + List.join("", captures0)
            else if(y == 8) " " + List.join("", captures1)
            else ""
    )
    |> Vector.reverse
    |> (it -> Vector.append(it, Vector#{"  0 1 2 3 4 5 6 7 8"}))
    |> Vector.join("\n")
    |> println

def move(x: Int32, y: Int32, x_: Int32, y_: Int32, promotes: Bool, board: Board): Option[(Option[Kind], Board)] =
    forM(
        square <- board |> Matrix.get(y, x);
        square_ <- board |> Matrix.get(y_, x_);
        piece <- square;
        boardMinus <- board |> Matrix.update(y, x, None);
        promoted = Bool.and(promotes,
            lazy if(piece.first) Bool.or(5 < y, lazy (5 < y_))
            else Bool.or(y <= 2, lazy (y_ <= 2)));
        board_ <- boardMinus |> Matrix.update(y_, x_, square |> Option.map(p -> {promoted = promoted | p}))
    )
        yield (square_ |> Option.map(p -> p.kind), board_)

def loop(
    history: List[(Board, List[Kind], List[Kind])],
    captures0: List[Kind],
    captures1: List[Kind],
    board: Board): Unit \ IO = {

    let turn = history |> List.length;
    let first = Int32.mod(turn, 2) == 0;

    printGame(board, captures0, captures1);
    "turn ${turn}: " ++ (if(first) Console.cyan("first player") else  Console.magenta("second player")) ++ "'s move" |> println;
    "> " |> System.StdOut.print;

    let input = Console.readLine() |> Result.toOption;

    if(input == Some("h")){
        println("ABCD(+): move piece AB to CD, maybe promoting");
        println("dNCD   : drop capture N to CD");
        println("z      : undo");
        println("q      : quit");
        println("h      : help");
        println("");
        loop(history, captures0, captures1, board)
    }
    else if(input == Some("q"))
        ()
    else if(input == Some("z"))
        match history {
            case Nil => {
                println("can't undo anymore");
                println("");
                loop(history, captures0, captures1, board)
            }
            case (board_, captures0_, captures1_):: history_ =>
                loop(history_, captures0_, captures1_, board_)
        }
    else {
        match input |> Option.map(String.split({regex = ""})) {
            case Some(a :: b :: c :: d :: tail) =>
                match if(a == "d")
                    forM(
                        n <- b |> Int32.parse(10) |> Result.toOption;
                        x <- c |> Int32.parse(10) |> Result.toOption;
                        y <- d |> Int32.parse(10) |> Result.toOption;
                        (kind, captures) <- (if(first) captures0 else captures1) |> List.pop(n);
                        board_ <- board |> Matrix.update(y, x, Some({first = first, promoted = false, kind = kind}))
                    )
                        yield loop(
                            (board, captures0, captures1) :: history,
                            if(first) captures else captures0,
                            if(first) captures1 else captures,
                            board_)
                else
                    forM(
                        x <- a |> Int32.parse(10) |> Result.toOption;
                        y <- b |> Int32.parse(10) |> Result.toOption;
                        x_ <- c |> Int32.parse(10) |> Result.toOption;
                        y_ <- d |> Int32.parse(10) |> Result.toOption;
                        (maybeKind, board_) <- board |> move(x, y, x_, y_, List.head(tail) == Some("+"))
                    )
                        yield match maybeKind {
                            case None =>
                                loop(
                                    (board, captures0, captures1) :: history,
                                    captures0, captures1, board_)
                            case Some(kind) =>
                                loop(
                                    (board, captures0, captures1) :: history,
                                    if(first) List.sort(kind :: captures0) else captures0,
                                    if(first) captures1 else List.sort(kind :: captures1),
                                    board_)
                        }
                {
                    case None => loop(history, captures0, captures1, board)
                    case Some(it) => it
                }
            case _ => loop(history, captures0, captures1, board)
        }
    }
}

def main(): Unit \ IO = {
    let row0 = Vector#{
        Kind.Lance,
        Kind.Knight,
        Kind.Silver,
        Kind.Gold,
        Kind.King,
        Kind.Gold,
        Kind.Silver,
        Kind.Knight,
        Kind.Lance
    };

    let board: Board = Vector#{
        row0 |> Vector.map(Some),
        Vector.repeat(9, None) |> Vector.update(1, Some(Kind.Bishop)) |> Vector.update(7, Some(Kind.Rook)),
        Vector.repeat(9, Some(Kind.Pawn)),
        Vector.repeat(9, None),
        Vector.repeat(9, None),
        Vector.repeat(9, None),
        Vector.repeat(9, Some(Kind.Pawn)),
        Vector.repeat(9, None) |> Vector.update(1, Some(Kind.Rook)) |> Vector.update(7, Some(Kind.Bishop)),
        row0 |> Vector.map(Some)
    }
    |> Vector.mapWithIndex(y ->
        Vector.map(it -> match it {
            case None => None
            case Some(kind) => Some({first = y <= 3, promoted = false, kind = kind})
        })
    );

    loop(List#{}, List#{}, List#{}, board)
}