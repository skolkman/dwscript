unit UHTMLFilterTests;

interface

uses
  Classes, SysUtils, dwsXPlatformTests, dwsComp, dwsCompiler, dwsExprs,
  dwsHtmlFilter, dwsXPlatform, dwsUtils;

type

   THTMLFilterTests = class(TTestCase)
   private
      FTests: TStringList;
      FCompiler: TDelphiWebScript;
      FFilter: TdwsHTMLFilter;
      FUnit: TdwsHTMLUnit;

   public
      procedure SetUp; override;
      procedure TearDown; override;

      procedure DoInclude(const scriptName: UnicodeString; var scriptSource: UnicodeString);

   published
      procedure TestHTMLScript;
      procedure TestPatterns;
      procedure TestSpecialChars;
      procedure TestNotClosed;
      procedure TestIncludeFiltered;
      procedure TestEditorMode;

   end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

// ------------------
// ------------------ THTMLFilterTests ------------------
// ------------------

// SetUp
//
procedure THTMLFilterTests.SetUp;
begin
  FTests := TStringList.Create;

  CollectFiles(ExtractFilePath(ParamStr(0)) + 'HTMLFilterScripts' + PathDelim, '*.dws', FTests);

  FCompiler := TDelphiWebScript.Create(nil);
  FCompiler.OnInclude := DoInclude;

  FFilter := TdwsHTMLFilter.Create(nil);
  FFilter.PatternOpen := '<?pas';
  FFilter.PatternClose := '?>';
  FFilter.PatternEval := '=';

  FCompiler.Config.Filter := FFilter;

  FUnit := TdwsHTMLUnit.Create(nil);
  FCompiler.AddUnit(FUnit);
end;

// TearDown
//
procedure THTMLFilterTests.TearDown;
begin
  FCompiler.Free;
  FFilter.Free;
  FUnit.Free;
  FTests.Free;
end;

procedure THTMLFilterTests.TestHTMLScript;
var
   s: string;
   resultFileName : String;
   prog: IdwsProgram;
   sl : TStringList;
   exec : IdwsProgramExecution;
begin
   sl:=TStringList.Create;
   try
      for s in FTests do begin
         sl.LoadFromFile(s);
         prog := FCompiler.Compile(sl.Text);

         CheckEquals('', prog.Msgs.AsInfo, s);
         exec:=prog.Execute;

         resultFileName:=ChangeFileExt(s, '.txt');
         if FileExists(resultFileName) then
            sl.LoadFromFile(ChangeFileExt(resultFileName, '.txt'))
         else sl.Clear;
         CheckEquals(sl.Text, exec.Result.ToString, s);
      end;
   finally
      sl.Free;
   end;
end;

// TestPatterns
//
procedure THTMLFilterTests.TestPatterns;
var
   locFilter : TdwsHtmlFilter;
begin
   locFilter:=TdwsHtmlFilter.Create(nil);
   try
      locFilter.PatternClose:='';
      CheckException(locFilter.CheckPatterns, EHTMLFilterException);
      locFilter.PatternClose:='a';

      locFilter.PatternOpen:='';
      CheckException(locFilter.CheckPatterns, EHTMLFilterException);
      locFilter.PatternOpen:='b';

      locFilter.PatternEval:='';
      CheckException(locFilter.CheckPatterns, EHTMLFilterException);
      locFilter.PatternEval:='c';
   finally
      locFilter.Free;
   end;
end;

// TestSpecialChars
//
procedure THTMLFilterTests.TestSpecialChars;
var
   prog: IdwsProgram;
   exec : IdwsProgramExecution;
begin
   prog:=FCompiler.Compile('hello'#10'world');
   exec:=prog.Execute;
   CheckEquals('hello'#10'world', exec.Result.ToString, '#10');

   prog:=FCompiler.Compile('hello'#9'world');
   exec:=prog.Execute;
   CheckEquals('hello'#9'world', exec.Result.ToString, '#9');

   prog:=FCompiler.Compile('''#13''');
   exec:=prog.Execute;
   CheckEquals('''#13''', exec.Result.ToString, 'apos');
end;

// TestNotClosed
//
procedure THTMLFilterTests.TestNotClosed;
var
   prog: IdwsProgram;
   exec : IdwsProgramExecution;
begin
   prog:=FCompiler.Compile('<?pas Send(''hello'');');
   exec:=prog.Execute;
   CheckEquals('hello', exec.Result.ToString, 'hello prog');

   prog:=FCompiler.Compile('<?pas var hello="world";?><?pas=hello');
   exec:=prog.Execute;
   CheckEquals('world', exec.Result.ToString, 'hello eval');
end;

// TestIncludeFiltered
//
procedure THTMLFilterTests.TestIncludeFiltered;
var
   prog: IdwsProgram;
   exec : IdwsProgramExecution;
begin
   prog:=FCompiler.Compile('a<?pas'#13#10'{$F "B"}'#13#10'?>c');
   exec:=prog.Execute;
   CheckEquals('aBc', exec.Result.ToString, 'include filtered 1');
end;

// DoInclude
//
procedure THTMLFilterTests.DoInclude(const scriptName: UnicodeString; var scriptSource: UnicodeString);
begin
   if scriptName='B' then
      scriptSource:='B'
   else scriptSource:=LoadTextFromFile('SimpleScripts\'+scriptName);
end;

// TestEditorMode
//
procedure THTMLFilterTests.TestEditorMode;
begin
   FFilter.BeginEditorMode;
   try
      CheckEquals('       N    ', FFilter.Process('a<?pas N ?>b', nil), '1');
      CheckEquals('      (N); ',  FFilter.Process('a<?pas=N?>b', nil), '2');
      CheckEquals('     N'#13#10'  '#13#10'     M  ',  FFilter.Process('<?pasN'#13#10'?>'#13#10'<?pasM?>', nil), '3');
   finally
      FFilter.EndEditorMode;
   end;
end;


// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

   RegisterTest('HTMLFilterTests', THTMLFilterTests);

end.
