%option yylineno

%{
#include <bits/stdc++.h>
using namespace std;

map<string, int> lexeme_count;
map<string, string> lexeme_token;
map<string, vector<string>> case_checking;
%}

%option caseless

WS                  [ \t\f\n\r]|\r\n
COMMENT             \{[^(\})]*\}
DELIMS              ","|";"|":"|"("|")"|"["|"]"|[\}]|[\{]    
DIGIT               [0-9]
LETTER              [a-zA-Z]
IDENTIFIER          {LETTER}({LETTER}|{DIGIT})*
STRING              \"(\\.|[^'\"])*\"|'(\\.|[^'\"])*'
NON_ZERO_DIGIT      [1-9]
NUMBER              ({NON_ZERO_DIGIT}{DIGIT}*)|0
HEX_DIGIT           [0-9a-fA-F]
NON_ZERO_HEX_DIGIT  [1-9a-fA-F]
HEXA                0(x|X)(0|{NON_ZERO_HEX_DIGIT}{HEX_DIGIT}*)
FLOAT               {NUMBER}"."{DIGIT}{1,6}

%%

{DELIMS} {
    lexeme_token[yytext] = "DELIMITER"; 
    lexeme_count[yytext]++;
}

{COMMENT} {/*lexeme_count["{"]++; lexeme_token["{"] = "DELIMITER";lexeme_count["}"]++; lexeme_token["}"] = "DELIMITER";*/}

{WS}

ARRAY|BEGIN|BOOLEAN|COMMENT|CONTINUE|DO|DOUBLE|ELSE|END|FALSE|FOR|IF|INTEGER|LABEL|LIST|LONG|OWN|PROCEDURE|STEP|SWITCH|THEN|TRUE|UNTIL|VALUE|WHILE {
    lexeme_token[yytext] = "KEYWORD"; 
    lexeme_count[yytext]++; 
    string newstr = yytext;
    for(auto &it:newstr){
        it = toupper(it);
    } 
    case_checking[newstr].push_back(yytext);
}

AND|OR|LEQ|LT|GEQ|GT|NOT|EQL|NEQ|":="|"+"|"-"|"*"|"/"|"%"|"^"|"|"|"&"|"<<"|">>"|">="|"<=" {
    lexeme_token[yytext] = "OPERATOR"; 
    lexeme_count[yytext]++;
    string newstr = yytext;
    for(auto &it:newstr){
        it = toupper(it);
    } 
    case_checking[newstr].push_back(yytext);
}

{IDENTIFIER} {
    lexeme_token[yytext] = "IDENTIFIER"; 
    lexeme_count[yytext]++;
}

{STRING} {
    lexeme_token[yytext] = "STRING"; 
    lexeme_count[yytext]++;
}

{NUMBER}  {
    lexeme_token[yytext] = "INTEGER"; 
    lexeme_count[yytext]++;
}

{FLOAT} {
    lexeme_token[yytext] = "FLOATING_POINT"; 
    lexeme_count[yytext]++;
}

{HEXA} {
    lexeme_token[yytext] = "HEXADECIMAL"; 
    lexeme_count[yytext]++;
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

[']([^'])* {
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

'(\\.|[^'\"])*[\"](\\.|[^'])*' {
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


