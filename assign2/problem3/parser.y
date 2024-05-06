%{
    #include<bits/stdc++.h>
    using namespace std;
    #define YYDEBUG 1

    extern int yylineno;
    extern int yylex(void);
    extern char *yytext;
    void yyerror(const char*);
    int total_questions = 0;
    int single_select_questions = 0;
    int multi_select_questions = 0;
    int overall_choices = 0;
    int overall_correct = 0;
    int total_marks = 0;
    vector<int> marks_quesiton(9,0);
    int block_choice = 0;
    int block_correct = 0;
    string error_msg = "";
    int line_parent_tag = 0;
    bool error_flag = false;
    extern stack<vector<int>> st;

    void print_out(void)
    {
        cout<<"Number of questions: "<<total_questions<<endl;
        cout<<"Number of singleselect questions: "<<single_select_questions<<endl;
        cout<<"Number of multiselect questions: "<<multi_select_questions<<endl;
        cout<<"Number of answer choices: "<<overall_choices<<endl;
        cout<<"Number of correct answers: "<<overall_correct<<endl;
        cout<<"Total marks: "<<total_marks<<endl;
        for(int i=1;i<=8;i++)
        {
            cout<<"Number of "<< i <<" marks questions: "<<marks_quesiton[i]<<endl;
        }
    }

    int get_marks(string inputString)
    {   
        int start = 0;
        int end;
        while ((start = inputString.find('"', start)) != std::string::npos)
        {
            start++;
            end = inputString.find('"', start);
            if (end != std::string::npos)
            {
                string substring = inputString.substr(start, end - start);
                int firstNonSpace = substring.find_first_not_of(" \t");
                int lastNonSpace = substring.find_last_not_of(" \t");

                if (firstNonSpace != std::string::npos && lastNonSpace != std::string::npos)
                {
                    substring = substring.substr(firstNonSpace, lastNonSpace - firstNonSpace + 1);
                    bool isNaturalNumber = true;
                    for (char c : substring)
                    {
                        if (!std::isdigit(c))
                        {
                            isNaturalNumber = false;
                            break;
                        }
                    }
                    if (isNaturalNumber)
                    {
                        return stoi(substring);
                    }
                }
                start = end + 1;
            }
            else
            {
                break;
            }
        }
        return 0;
    }

    void print_error(void)
    {
        cerr<<error_msg<<endl;
        print_out();
        exit(1);
    }

%}

%union{
    char *strval;
}

%token<strval> QUIZ_START QUIZ_END CHOICE_START CHOICE_END CORRECT_START CORRECT_END SINGLESELECT_START SINGLESELECT_END MULTISELECT_START MULTISELECT_END 

%type question_body choice correct quiz_body single_select_question multi_select_question

%start Compilation

%%

Compilation : QUIZ_START quiz_body QUIZ_END {
    if(error_flag){ 
        print_error();
    }
}

quiz_body : 
        | single_select_question quiz_body
        | multi_select_question quiz_body
        ;


multi_select_question: MULTISELECT_START question_body MULTISELECT_END {
    // cout<<"rule detected\n";
  
    if(error_flag)
    {
        print_error();
    }
    string tmp = $1;
    int marks = get_marks(tmp);
    total_marks += marks;
    multi_select_questions++; 
    total_questions++;
    if(marks < 2 || marks > 8)
    {
        error_msg = "Error: <multiselect> at line " + to_string(line_parent_tag) + "\nMarks = " + to_string(marks) + " out of range: marks of <multiselect> can range from 2 to 8.\n";
        print_error();
    }
    marks_quesiton[marks]++;
        
    if(block_choice != 3 && block_choice != 4)
    {
        error_msg = "Error: <multiselect> at line " + to_string(line_parent_tag) + "\nChoices out of range: number of choices can range from 3 to 4\n";
        print_error();
    }
    if(block_correct > block_choice)
    {
        error_msg = "Error: <multiselect> at line " + to_string(line_parent_tag) + "\nCorrect choices: " + to_string(block_correct) + " Total choices: " + to_string(block_choice) + " correct options greater than total options\n";
        print_error();
    }
    block_choice = 0;
    block_correct = 0;
   
}

single_select_question: SINGLESELECT_START question_body SINGLESELECT_END {
    // cout<<"rule detected\n";
    
    if(error_flag)
    {
        print_error();
    }
    string tmp = $1;
    int marks = get_marks(tmp);
    total_marks += marks;
    single_select_questions++; 
    total_questions++;
    if(marks != 1 && marks != 2)
    {
        error_msg = "Error: <singleselect> at line " + to_string(line_parent_tag) + "\nMarks = " + to_string(marks) + " out of range: marks of <singleselect> can range from 1 to 2.\n";
        print_error();
    }
    marks_quesiton[marks]++;
    if(block_choice != 3 && block_choice != 4)
    {
        error_msg = "Error: <singleselect> at line " + to_string(line_parent_tag) + "\nChoices out of range: number of choices can range from 3 to 4\n";
        print_error();
    }
    if(block_correct != 1)
    {
        error_msg = "Error: <singleselect> at line " + to_string(line_parent_tag) + "\nCorrect choices out of range: number of correct choices should be 1 in <singleselect>\n";
        print_error();
    }
    block_choice = 0;
    block_correct = 0;
}

question_body : 
           | choice question_body 
           | correct question_body 
           ;

choice : CHOICE_START CHOICE_END { block_choice++; overall_choices++;}
correct : CORRECT_START CORRECT_END { block_correct++;overall_correct++;}

%%

int main()
{
    yyparse();
    if(!st.empty())
    {
        vector<int> v = st.top();
        string tag = "";
        if(v[2]==0) tag="<quiz>";
        if(v[2]==1) tag="<singleselect>";
        if(v[2]==2) tag="<multiselect>";
        if(v[2]==3) tag="<choice>";
        if(v[2]==4) tag="<correct>";
        error_msg = "Error: No closing tag for "+ tag+" at line "+to_string(v[1]);
        print_error();
    }
    print_out();
}

void yyerror(const char* s) {
    ;
    /* fprintf(stderr, "Line number:%d Error: %s\n",yylineno, s); */
}