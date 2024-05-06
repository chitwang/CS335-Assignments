%option yylineno
%option noyywrap
%option case-insensitive

%{
    #include<bits/stdc++.h>
    #include "parser.tab.h"
    using namespace std;
    stack<vector<int>> st;
    extern bool error_flag;
    extern string error_msg;
    extern int line_parent_tag;
    extern void print_error(void);
%}

WHITESPACE          [ \t\n\r]
QUIZ                "quiz"
CHOICE              "choice"
CORRECT             "correct"
SINGLESELECT        "singleselect"
MULTISELECT         "multiselect"
MARKS               "marks"
OPEN                "<"
CLOSE               ">"
SLASH               "/"
NON_CLOSE           {WHITESPACE}|[^>]
IGNORE_GARBAGE      [^<>/=\"]
NATURAL_NUMBER      [1-9][0-9]*
MARKS_VAL           [\"]{WHITESPACE}*{NATURAL_NUMBER}{WHITESPACE}*[\"]
MARKS_VAL_2         [\"]?{WHITESPACE}*{NATURAL_NUMBER}{WHITESPACE}*[\"]?
EQUALTO             "="

QUIZ_START          {OPEN}{IGNORE_GARBAGE}*{QUIZ}{IGNORE_GARBAGE}*{CLOSE}
QUIZ_END            {OPEN}{IGNORE_GARBAGE}*{SLASH}{IGNORE_GARBAGE}*{QUIZ}{IGNORE_GARBAGE}*{CLOSE}

CHOICE_START        {OPEN}{IGNORE_GARBAGE}*{CHOICE}{IGNORE_GARBAGE}*{CLOSE}
CHOICE_END          {OPEN}{IGNORE_GARBAGE}*{SLASH}{IGNORE_GARBAGE}*{CHOICE}{IGNORE_GARBAGE}*{CLOSE}

CORRECT_START       {OPEN}{IGNORE_GARBAGE}*{CORRECT}{IGNORE_GARBAGE}*{CLOSE}
CORRECT_END         {OPEN}{IGNORE_GARBAGE}*{SLASH}{IGNORE_GARBAGE}*{CORRECT}{IGNORE_GARBAGE}*{CLOSE}

SINGLESELECT_START  {OPEN}{IGNORE_GARBAGE}*{SINGLESELECT}{WHITESPACE}{IGNORE_GARBAGE}*{MARKS}(({WHITESPACE}+{IGNORE_GARBAGE}*)|({WHITESPACE}*)){EQUALTO}{IGNORE_GARBAGE}*{MARKS_VAL}{IGNORE_GARBAGE}*{CLOSE}

E_SINGLESELECT_START  {OPEN}{IGNORE_GARBAGE}*{SINGLESELECT}{WHITESPACE}{IGNORE_GARBAGE}*{MARKS}(({WHITESPACE}+{IGNORE_GARBAGE}*)|({WHITESPACE}*)){EQUALTO}{IGNORE_GARBAGE}*{MARKS_VAL_2}{IGNORE_GARBAGE}*{CLOSE}

E_SINGLESELECT_START1  {OPEN}{IGNORE_GARBAGE}*{SINGLESELECT}{NON_CLOSE}*{CLOSE}

SINGLESELECT_END    {OPEN}{IGNORE_GARBAGE}*{SLASH}{IGNORE_GARBAGE}*{SINGLESELECT}{IGNORE_GARBAGE}*{CLOSE}

MULTISELECT_START   {OPEN}{IGNORE_GARBAGE}*{MULTISELECT}{WHITESPACE}{IGNORE_GARBAGE}*{MARKS}(({WHITESPACE}+{IGNORE_GARBAGE}*)|({WHITESPACE}*)){EQUALTO}{IGNORE_GARBAGE}*{MARKS_VAL}{IGNORE_GARBAGE}*{CLOSE}

E_MULTISELECT_START   {OPEN}{IGNORE_GARBAGE}*{MULTISELECT}{WHITESPACE}{IGNORE_GARBAGE}*{MARKS}(({WHITESPACE}+{IGNORE_GARBAGE}*)|({WHITESPACE}*)){EQUALTO}{IGNORE_GARBAGE}*{MARKS_VAL_2}{IGNORE_GARBAGE}*{CLOSE}

E_MULTISELECT_START1  {OPEN}{IGNORE_GARBAGE}*{MULTISELECT}{NON_CLOSE}*{CLOSE}

MULTISELECT_END     {OPEN}{IGNORE_GARBAGE}*{SLASH}{IGNORE_GARBAGE}*{MULTISELECT}{IGNORE_GARBAGE}*{CLOSE}


%%

{WHITESPACE} {}

{QUIZ_START} {
    string tmp = yytext;
    int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
    if(!st.empty())
    {
        // error
        error_msg = "Error: <quiz> at line " + to_string(num)+". There can be only 1 <quiz> at the topmost level.\n";
        print_error();
    }
    else
    {
        st.push({0, num, 0});
        // cout<<"quiz started at line no "<<yylineno << endl; 
        return QUIZ_START;
    }
}

{QUIZ_END} {
    string tmp = yytext;
    int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
    if(st.empty() || st.top()[2] != 0)
    {
        // separate error cases
        error_msg = "Error: stray closing </quiz> at line "+to_string(num)+"\n";
        print_error();
    }
    else
    {
        st.pop();
        return QUIZ_END;
    }
}

{SINGLESELECT_START} {
    if(!st.empty())
    {
        string tmp = yytext;
        int num = yylineno - count(tmp.begin(), tmp.end(), '\n'); 
        if(st.top()[0] == 0)
        {
            st.push({1,num, 1});
            line_parent_tag = num;
            yylval.strval = strdup(yytext);
            return SINGLESELECT_START;
        }
        else
        {
            // if multiselect/single khula hua to wo close ni hua error 
            // if choice ya correct to niche line wala error
            if(st.top()[0] == 2){
                error_msg = "Error: Invalid hierarchy of <singleselect> at line "+to_string(num)+". Only <quiz> can be the parent of <singleselect>\n";
            }
            else if (st.top()[2] == 1){
                error_msg = "Error: Missing closing tag for <singleselect> opened at line "+to_string(st.top()[1])+"\n";
            }
            else if (st.top()[2] == 2){
                error_msg = "Error: Missing closing tag for <multiselect> opened at line "+to_string(st.top()[1])+"\n";
            }
            print_error();
        }
    }
}

{SINGLESELECT_END} {
    if(!st.empty())
    {
        string tmp = yytext;
        int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
        if(st.top()[2] != 1)
        {
            
            error_msg = "Error: stray closing </singleselect> at line "+to_string(num)+"\n";
            print_error();
        }
        else
        {
            st.pop();
            return SINGLESELECT_END;
        }
    }
}

{MULTISELECT_START} {
    if(!st.empty())
    {
        string tmp = yytext;
        int num = yylineno - count(tmp.begin(), tmp.end(), '\n'); 
        if(st.top()[0] == 0)
        {
            st.push({1,num, 2});
            line_parent_tag = num;
            yylval.strval = strdup(yytext);
            return MULTISELECT_START;
        }
        else
        {
            if(st.top()[0] == 2){
                error_msg = "Error: Invalid hierarchy of <multiselect> at line "+to_string(num)+". Only <quiz> can be the parent of <multiselect>\n";
            }
            else if (st.top()[2] == 1){
                error_msg = "Error: Missing closing tag for <singleselect> opened at line "+to_string(st.top()[1])+"\n";
            }
            else if (st.top()[2] == 2){
                error_msg = "Error: Missing closing tag for <multiselect> opened at line "+to_string(st.top()[1])+"\n";
            }
            print_error();
            // error wrong tag hierarchy 
        }
    }
}

{MULTISELECT_END} {
    if(!st.empty())
    {
        string tmp = yytext;
        int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
        if(st.top()[2] != 2)
        {
            // error invalid closing tag
            error_msg = "Error: stray closing </multiselect> at line "+to_string(num)+"\n";
            print_error();
        }
        else
        {
            st.pop();
            return MULTISELECT_END;
        }
    }
}

{CHOICE_START} {
    if(!st.empty())
    {
        string tmp = yytext;
        int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
        if(st.top()[0] == 1)
        {
            st.push({2, num, 3});
            return CHOICE_START;
        }
        else
        {
            // error wrong hierarchy
            // if quiz k andar h to yehi error
            if(st.top()[0] == 0){
                error_msg = "Error: Invalid hierarchy of <choice> at line " + to_string(num) + ". <choice> can be present only inside a question\n";
            }
            else if(st.top()[2] == 3){
                error_msg = "Error: Missing closing tag for <choice> opened at line "+to_string(st.top()[1])+"\n";
            }
            else if(st.top()[2] == 4){
                error_msg = "Error: Missing closing tag for <correct> opened at line "+to_string(st.top()[1])+"\n";
            }
            // else missing closing
            print_error();
        }
    }
}

{CHOICE_END} {
    if(!st.empty())
    {
        string tmp = yytext;
        int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
        if(st.top()[2] == 3)
        {
            st.pop();
            return CHOICE_END;
        }
        else 
        {
            // stray tag choice closing errro agr bade 
            error_msg = "Error: stray closing </correct> at line "+to_string(num)+"\n";
            print_error();
        }
    }
}

{CORRECT_START} {
    if(!st.empty())
    {
        string tmp = yytext;
        int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
        if(st.top()[0] == 1)
        {
            st.push({2, num, 4});
            return CORRECT_START;
        }
        else
        {
            // error wrong hierarchy
            if(st.top()[0] == 0){
                error_msg = "Error: Invalid hierarchy of <correct> at line " + to_string(num) + ". <correct> can be present only inside a question\n";
            }
            else if(st.top()[2] == 3){
                error_msg = "Error: Missing closing tag for <choice> opened at line "+to_string(st.top()[1])+"\n";
            }
            else if(st.top()[2] == 4){
                error_msg = "Error: Missing closing tag for <correct> opened at line "+to_string(st.top()[1])+"\n";
            }
            print_error();
        }
    }
}

{CORRECT_END} {
    if(!st.empty())
    {
        string tmp = yytext;
        int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
        if(st.top()[2] == 4)
        {
            st.pop();
            return CORRECT_END;
        }
        else 
        {
            // stray tag cORRECT closing errro
            error_msg = "Error: stray closing </correct> at line "+to_string(num)+"\n";
            print_error();
        }
    }
}

{E_SINGLESELECT_START} {
    // ERROR INVALID SINGLESELECT
    string tmp = yytext;
    int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
    error_msg = "Error: Invalid syntax <singleselect> at line "+ to_string(num)+ "\n";
    error_flag = true;
    print_error();
    return SINGLESELECT_START;
}

{E_MULTISELECT_START} {
    //ERROR INVALID MULTISELECT
    string tmp = yytext;
    int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
    error_msg = "Error: Invalid syntax <multiselect> at line "+ to_string(num)+"\n";
    error_flag = true;
    print_error();
    return MULTISELECT_START;
}

{E_SINGLESELECT_START1} {
    // ERROR INVALID SINGLESELECT
    // cout<<yytext<<endl;
    string tmp = yytext;
    int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
    error_msg = "Error: Invalid syntax <singleselect> at line "+ to_string(num)+ "\n";
    error_flag = true;
    print_error();
    return SINGLESELECT_START;
}

{E_MULTISELECT_START1} {
    //ERROR INVALID MULTISELECT
    string tmp = yytext;
    int num = yylineno - count(tmp.begin(), tmp.end(), '\n');
    error_msg = "Error: Invalid syntax <multiselect> at line "+ to_string(num)+"\n";
    error_flag = true;
    print_error();
    return MULTISELECT_START;
}

. {}

%%