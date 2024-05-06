%option yylineno

%{
#include <bits/stdc++.h>
using namespace std;

map<string, int> lexeme_count;
map<string, string> lexeme_token;
map<string, vector<string>> case_checking;
%}

%option case-insensitive

WS              [ \t\f\n\r]|\r\n
COMMENT         ^[ \t]*!([^\n]*)[\n]?
DELIMS          "("|")"|"["|"]"|"(/"|"/)"
SPECIAL         ","|":"|"."|"@"|"#"|"$"|"|"|"^"|"`"|"~"|"?"|";"|[\{]|[\}]|"\\"|[\"]|"!"|"'"
DIGIT           [0-9]
LETTER          [a-zA-Z]
NAME            {LETTER}({LETTER}|{DIGIT}|"_"){0,62}
DIGIT_STRING    {DIGIT}+
PERIOD          "."
SIGNIFICAND     ({PERIOD}{DIGIT_STRING})|({DIGIT_STRING}{PERIOD}{DIGIT_STRING}?)
EXPONENT_LETTER [EeDd]
SIGN            [+-]
EXPONENT        ({SIGN}?{DIGIT_STRING})
POWERS          {EXPONENT_LETTER}{EXPONENT} 
FLOAT           {SIGN}?({SIGNIFICAND}({POWERS}?))|({DIGIT_STRING}{POWERS})
BOOL            ".TRUE."|".FALSE."
CHARL           (\"([^'\"]*)\")


%%

{DELIMS} {lexeme_token[yytext] = "DELIMITER"; lexeme_count[yytext]++;}

{COMMENT} {/* lexeme_count["{"]++; lexeme_token["{"] = "DELIMITER";lexeme_count["}"]++; lexeme_token["}"] = "DELIMITER";*/}

{WS}

allocatable|allocate|assign|associate|asynchronous|backspace|bind|call|case|class|close|common|contains|continue|cycle|codimension|contiguous|critical|data|deallocate|deferred|dimension|do|else|elsewhere|end|endfile|endif|entry|equivalence|exit|external|enum|enumerator|extends|forall|final|flush|format|function|goto|generic|import|if|implicit|inquire|intrinsic|include|interface|intent|lock|module|nopass|namelist|nullify|open|only|operator|optional|parameter|pause|print|program|pointer|private|pass|protected|procedure|public|read|return|recursive|result|rewind|rewrite|save|stop|subroutine|select|sequence|submodule|target|then|use|value|unlock|volatile|while|write {
    lexeme_token[yytext] = "KEYWORD"; 
    lexeme_count[yytext]++;
    string newstr = yytext;
    for(auto &it:newstr){
        it = toupper(it);
    } 
    case_checking[newstr].push_back(yytext);
}

"="|"+"|"-"|"*"|"/"|"%"|">"|"<"|"&"|"&&"|">>"|"<<"|"||"|"**"|"=="|"<="|">="|"//"|"/="|".EQ."|".NE."|".GT."|".GE."|".LE."|".LT."|".NOT."|".AND."|".OR."|".EQV."|".NEQV." {
    lexeme_token[yytext] = "OPERATOR"; 
    lexeme_count[yytext]++;
    string newstr = yytext;
    for(auto &it:newstr){
        it = toupper(it);
    } 
    case_checking[newstr].push_back(yytext);
}

{NAME} {
    lexeme_token[yytext] = "NAME"; 
    lexeme_count[yytext]++;
    string newstr = yytext;
    for(auto &it:newstr){
        it = toupper(it);
    } 
    case_checking[newstr].push_back(yytext);
}

{SPECIAL} {
    lexeme_token[yytext] = "SPECIAL_CHAR"; 
    lexeme_count[yytext]++;
}

{SIGN}?{DIGIT_STRING} {
    lexeme_token[yytext] = "INT_LITERAL"; 
    lexeme_count[yytext]++;
}

{BOOL} {
    lexeme_token[yytext] = "LOGICAL_LITERAL"; 
    lexeme_count[yytext]++;
    string newstr = yytext;
    for(auto &it:newstr){
        it = toupper(it);
    } 
    case_checking[newstr].push_back(yytext);
}

{CHARL} {
    lexeme_token[yytext] = "CHAR_LITERAL"; 
    lexeme_count[yytext]++;
}

{FLOAT} {
    lexeme_token[yytext] = "REAL_LITERAL";
    lexeme_count[yytext]++;
    string newstr = yytext;
    for(auto &it:newstr){
        it = toupper(it);
    }
    case_checking[newstr].push_back(yytext);
}

[\"](\\.|[^'\"])*'(\\.|[^\"])*[\"] {
        for(auto it:case_checking)
        {
                for(auto vec:it.second)
                {
                        lexeme_count[vec] = it.second.size();
                }
        }
    cout <<"TOKEN    COUNT    LEXEME" << endl;
    for (auto it : lexeme_token) {
        cout <<it.second << "    " << lexeme_count[it.first] << "    " << it.first << endl;
	}
        string newstr = yytext;
        cout<<"Invalid string "<<yytext<<" at line number "<<yylineno - count(newstr.begin(), newstr.end(), '\n')<<endl;
        exit(1);	
}

[\"]([^\"])* {
        for(auto it:case_checking)
        {
                for(auto vec:it.second)
                {
                        lexeme_count[vec] = it.second.size();
                }
        }
    cout <<"TOKEN    COUNT    LEXEME" << endl;
    for (auto it : lexeme_token) {
        cout <<it.second << "    " << lexeme_count[it.first] << "    " << it.first << endl;
	}
        string newstr = yytext;
        cout<<"Invalid string "<<yytext<<" at line number "<<yylineno - count(newstr.begin(), newstr.end(), '\n')<<endl;
        exit(1);
}

. {
	for(auto it:case_checking)
        {
                for(auto vec:it.second)
                {
                        lexeme_count[vec] = it.second.size();
                }
        }
    cout <<"TOKEN    COUNT    LEXEME" << endl;
    for (auto it : lexeme_token) {
        cout <<it.second << "    " << lexeme_count[it.first] << "    " << it.first << endl;
	}
        cout<<"Invalid token/character at line number "<<yylineno<<endl;
        exit(1);
}

%%

int main() {
    yylex();
    for(auto it:case_checking)
    {
        for(auto vec:it.second)
        {
            lexeme_count[vec] = it.second.size();
        }
    }
    cout <<"TOKEN    COUNT    LEXEME" << endl;
    for (auto it : lexeme_token) {
        cout <<it.second << "    " << lexeme_count[it.first] << "    " << it.first << endl;
	}
    return 0;
}
