// @Author Scott Holden
// UCID: 30051473
// Final Project
//
//

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <string.h>

void initializeGame(float *board, char *moves, int dim, int min, int max);

float randomNum(float n, float m, bool neg);

void playerMove(float *board, char *moves, int row, int column, int dim);

void displayGame(char *moves, int dim, float score, long time_remaining);

float calculateScore(char operation, float turn_score, float total_score);

void logScore(FILE *fptr, char *pname, float final_score, long time);

void exitGame(FILE *fptr);

void displayTopScores(FILE *fptr, int n);

long timerLength(int dim);

int main(int argc, char *argv[]) {
	
	if(argc == 3){
		
		char player_name[16] ;
		int n = atoi(argv[2]);
		strcpy(player_name, argv[1]);
		char *pname_ptr = &player_name[0];
		
		long max_secs = 60;
		float score = 0;
		int move_count = 0;
		
		float board[n][n];
		float *board_ptr = &board[0][0];
		
		char moves[n][n];
		char *move_ptr = &moves[0][0];
		
		FILE *write_fptr;
		write_fptr = fopen("leaderboard.log", "a+");
	
		initializeGame(board_ptr, move_ptr, n, 0, 15);
		max_secs = timerLength(n);
		displayGame(move_ptr, n, score, max_secs);
		
		time_t time_0 = time(NULL);
		long sec_count = 0;
		
		int row;
		int column;
		char quit_key;
		
		do{
			printf("\n");
			printf("Enter your move (row, column), or q to quit: ");
			scanf("%d %d", &row, &column);
			scanf("%c", &quit_key);
			if (quit_key == 'q') {
				exitGame(write_fptr);
				return 0;
			}
			else if(moves[row][column] == 'X'){
				playerMove(board_ptr, move_ptr, row, column, n);
				score = calculateScore(moves[row][column], board[row][column], score);
				sec_count =(time(NULL) - time_0);
				displayGame(move_ptr, n, score, max_secs - sec_count);
				move_count++;
			}
		}
		while ((move_count < (n * n)) && (score > 0) && (sec_count < max_secs));
		
		logScore(write_fptr, pname_ptr, score, sec_count);
		exitGame(write_fptr);
	}
    return 0;
}


// Incomplete
void displayTopScores(FILE *fptr, int n){
//	char ch;
//	char arr[n][3];
//	while ((ch = fgetc(fptr)) != EOF) {
//		// something
//		for (int i = 0; i < n; i++) {
//			for (int j = 0; j < 3; j ++) {
//				<#statements#>
//			}
//		}
//
//	}
}

void exitGame(FILE *fptr){
	fclose(fptr);
}

/// 2D matrix to log file
/// @param fptr log file pointer
/// @param pname char array pointer
/// @param final_score final score
/// @param time elapsed time
void logScore(FILE *fptr, char *pname, float final_score, long time){
	if(fptr == NULL){
        printf("Error");
        exit(1);
    }
	fprintf(fptr, "%.2f", final_score);
	fprintf(fptr, "%ld", time);
	fprintf(fptr, "%s", pname);
	fprintf(fptr, "\n");
}


/// RNG. returns random float [n,m] assuming n < m.
/// When neg == true, result will be negative.
/// @param n lower bound
/// @param m upper bound
/// @param neg sign of random number
float randomNum(float n, float m, bool neg){
    float scale = rand() / (float) RAND_MAX;
    float result = n + scale * (m - n);

    if(neg){
//        result = ~result + 1;
        result = (-1)* result;
    }
    return result;
}


/// based on value of board[row][column], different operation is stored in moves[row][column]
/// @param board 2D array of float score values
/// @param moves 2D Array of '$','!',+','-', 'X'.
/// @param row [0,...,dim]
/// @param column [0,...,dim]]
/// @param dim =N
void playerMove(float *board, char *moves, int row, int column, int dim){
	char cell;
	if(*(board + (row * dim) + column) > 1 ){
		cell = '+';
		printf("Reward! %.2f points", *(board + (row * dim) + column));
	}
	else if(*(board + (row * dim) + column) < -1 ){
		cell = '-';
		printf("Bomb! %.2f points.", *(board + (row * dim) + column));
	}
	else if(*(board + (row * dim) + column) > 0){
		cell = '$';
		printf("Double Score!");
	}
	else {
		cell = '!';
		printf("Half Score...");
	}
	*(moves + (row * dim) + column) = cell;
}

/// returns overall score
/// @param operation '$','!',+','-'
/// @param turn_score add or subtract
/// @param total_score current score of player
float calculateScore(char operation, float turn_score, float total_score){
	switch (operation) {
		case '$':
			return (int)total_score << 1;
			break;
		case '!':
			return (int)total_score >> 1;
			break;
		default:
			return total_score += turn_score;
			break;
	}
}


/// initialize arrays.
/// board is randomly filled with float values, 1/5th of which are negative
/// moves is filled with 'X',
/// @param board 2D array of float score values
/// @param moves 2D Array of '$','!',+','-', 'X'.
/// @param dim =N
/// @param min lower bound on rand
/// @param max upper bound on rand
void initializeGame(float *board, char *moves,int dim, int min, int max){
    int i, j;
    float rand;
    bool sign = false;
    time_t t;
    
    srand((unsigned) time(&t));
    for (i = 0; i < dim; i++){
        for (j = 0; j < dim; j++){
            if((int)randomNum(0, 5, false) == 1){sign = true;}
            rand = randomNum(min, max, sign);
            sign = false;
            *((board + i * dim) + j) = rand;
            *((moves + i * dim) + j) = 'X';
        }
    }
}

/// prints current game state
/// @param board 2D Array of '$','!',+','-', 'X'
/// @param dim =N
/// @param score current player score
/// @param time_remaining time remaining in game
void displayGame(char *board, int dim, float score, long time_remaining){
    int i, j;

    for (i = 0; i < dim; i++){
        printf("\n");
        for (j = 0; j < dim; j++){
            printf("%c ", *(board + (i * dim) + j));
        }
        printf("\n");
    }
    printf("Score: %.2f\n", score);
    printf("Time: %ld s\n", time_remaining);
}

/// Increases timer by increments of 20.
/// @param dim  = N
long timerLength(int dim){
	long seconds = 60;
	switch (dim) {
		case 5:
			seconds = 60;
			break;
		case 6:
			seconds = 80;
			break;
		case 7:
			seconds = 100;
			break;
		case 8:
			seconds = 120;
			break;
		case 9:
			seconds = 140;
			break;
		case 10:
			seconds = 160;
			break;
		case 11:
			seconds = 180;
			break;
		case 12:
			seconds = 200;
			break;
		case 13:
			seconds = 220;
			break;
		case 14:
			seconds = 240;
			break;
		case 15:
			seconds = 260;
			break;
		default:
			seconds = 300;
			break;
	}
	return seconds;
}
 
 

