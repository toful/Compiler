#include <stdio.h>
#include <stdlib.h>
#include "compiler.h"

int main( int argc, char *argv[] ){
    int error;

    if (argc == 3){
        error = init_lexic_analysis(argv[1]);
        
        if(error == EXIT_SUCCESS){
            error =  init_syntactic_analysis(argv[2]);
            
            if(error == EXIT_SUCCESS){
                error = semantic_analysis();
                
                if( error == EXIT_SUCCESS ) printf("The compilation has been successful\n");
                else printf("ERROR\n");
                
                error = end_syntactic_analysis();
                if( error == EXIT_FAILURE ) printf("The output file can not be closed\n");
                
                error = end_lexic_analysis();
                if( error == EXIT_FAILURE ) printf("The input file can not be closed\n");
            }
            else printf("The output file %s can not be created\n", argv[2] );
        }
        else printf("The input file %s can not be opened\n", argv[1] );
    }
    else printf("\nUsage: %s INPUT_FILE OUTPUT_FILE\n", argv[0] );
    
    return EXIT_SUCCESS;
}