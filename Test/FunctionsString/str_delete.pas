PrintLn(StrDeleteLeft('banana', 2));
PrintLn(StrDeleteRight('banana', 2));

PrintLn(StrDeleteLeft('banana', 20));
PrintLn(StrDeleteRight('banana', 20));

PrintLn(StrDeleteLeft('banana', -1));
PrintLn(StrDeleteRight('banana', -1));

var s := 'banana';

PrintLn(s.DeleteLeft(2));
PrintLn(s.DeleteRight(2));

PrintLn(s.DeleteLeft(20));
PrintLn(s.DeleteRight(20));

PrintLn(s.DeleteLeft(-1));
PrintLn(s.DeleteRight(-1));
