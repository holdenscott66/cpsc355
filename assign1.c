// CPSC 355 Assignment 1
// Created by Scott Holden
// UCID: 30051473

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void initialize(int *table, int num_rows, int num_cols, int min, int max);

int randomNum(int n, int m);

void display(int *table, int rows, int cols);

void sort(int *table, int num_rows, int num_cols, int sort_column);

void logFile(int *table, int *sort_column, int num_rows, int num_columns);

int main(int argc, char *argv[]){
    
    if (argc == 2){
        int n = atoi(argv[1]);
        int arr[n][n];
        int *ptr = &arr[0][0];
                        
        int sort_column;
       
        initialize(ptr, n, n, 0, 9);
        display(ptr, n, n);
        logFile(ptr, NULL, n, n);
        
        int quit = 0;
        
        do
        {
            printf("\n");
            printf("Enter a column number [0,%d]: ", n-1);
            scanf("%d", &sort_column);

            
            if((sort_column <= (n-1)) && (sort_column >= 0)){
                
                sort(ptr, n, n, sort_column);
                printf("Table sorted by column %d:\n", sort_column);
                
                display(ptr, n, n);
                printf("\n");
                
                logFile(ptr, &sort_column, n, n);
                
                printf("Enter 0 to sort again or 1 to quit:\n");
                scanf("%d", &quit);
            }
        }
        while (!quit);
        
        logFile(ptr, NULL, n, n);
    }
    else if (argc > 2){
        printf("Too many arguments supplied.\n");
    }
    else {
        printf("One argument expected.\n");
    }
   
	return 0;
}

// Fills n x n matrix with random integers in [min, max]
void initialize(int *table, int num_rows, int num_cols, int min, int max){
    int row, column, rand;

    srand(time(0));
    
    for (row = 0; row < num_rows; row++){
        for (column = 0; column < num_cols; column++){
            rand = randomNum(min, max);
            *((table + row * num_cols) + column) = rand;
        }
    }
}

// Print n x n matrix
void display(int *table, int rows, int cols){
    int i, j;
    
    for (i = 0; i < rows; i++){
        printf("\n");
        for (j = 0; j < cols; j++){
            printf("%d ", *(table + (i * cols) + j));
        }
        printf("\n");
    }
}

// returns random integer in [n,m] when m > n or [m,n] when n > m
int randomNum(int n, int m){
    int result = 0, min = 0, max = 0;
    
    if (n < m){
        min = n;
        max = m + 1; // include bound
    }
    else{
        min = m;
        max = n + 1;
    }
    
    return (rand() % (max - min)) + min;
}

//sorts n x n matrix by column number
void sort(int *table, int num_rows, int num_cols, int sort_column){
    int i, j, k, temp;
    
    for (i = 0; i < num_rows; i++){
        for (j = i+1; j < num_rows; j++){
            if (*(table + (i * num_cols) + sort_column) > *(table + (j * num_cols) + sort_column)){
                for(k = 0; k < num_cols; k++){
                    temp = *(table + (i * num_cols) + k);
                    *(table + (i * num_cols) + k) = *(table + (j * num_cols) + k);
                    *(table + (j * num_cols) + k) = temp;
                }
            }
        }
    }
}

// writes to assign1.log
// sort_column reference determines what is written to log file
void logFile(int *table, int *sort_column, int num_rows, int num_columns){
    FILE *fptr;
    
    fptr = fopen("assign1.log", "a");
    
    if(fptr == NULL){
        printf("Error");
        exit(1);
    }
    
    if(sort_column == NULL){
        for (int i = 0; i < num_rows; i++){
            for (int j = 0; j < num_columns; j++){
                fprintf(fptr, "%d ", *(table + (i * num_columns)+j));
            }
            fprintf(fptr, "\n");
        }
        fprintf(fptr, "\n");
    }
    
    else{
        fprintf(fptr, "Sorted by column: %d\n", *sort_column);
    }
    
    fclose(fptr);
}
