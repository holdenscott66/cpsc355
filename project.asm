// @Author Scott Holden
// UCID: 30051473
//  
// Final Project
// 
//
//
message1:	.string "Reward. %.2f points \n"
message2:	.string "Bomb.  %.2f points \n"
message3:	.string "Double Score.\n"
message4:	.string "Half Score.\n"

score_out:	.string "Score: %.2f \n"
time_out:	.string "Time Remaining: %ld s\n"
newLine:	.string "\n"
float_out: 	.string "%.2f  \n"
char_out:	.string "%c "

prompt:		.string "Enter your move (row, column), or ^Z to quit: \n"
fmt_in:		.string	"%d"
char_in:	.string "%c"

n_r	.req 	x19
i_r	.req	x20
j_r	.req	x21
temp_r	.req	x22
base_r	.req	x23
alloc_r	.req	x24
quit_r	.req	x25
move_r	.req	x26
timer_r	.req	x27
score_r	.req	d19



// ---------------------------------------------------------- main ------------------------------------------------------------ //
// Game Structure setup

game_dim = 0
game_score = 8
game_timeCount = 16
game_timeMax = 24
game_size =  32

game_offset = 16

	.balign 4
	.global main
main:
	stp	x29,	x30,	[sp, -(16 + 32) & -16]!		// allocate memory
	mov	x29,	sp					// x29 = stack pointer
	
	mov	temp_r,	x1					// temp = argv[]
	ldr	x0,	[temp_r, 8]				// x0 = argv[1]
	bl	atoi						// branch link to atoi 
	mov	n_r,	x0					// store value in n register

//	mov	n_r,	5					// for debugging 
								
	// initialize game Structure
	str	n_r,	[x29,	game_offset + game_dim]		// store n on stack

	mov 	x9,	0					// game.score = 0.0
	scvtf	score_r,x9					// d9 = (float)x9
	str	score_r,[x29,	game_offset + game_score]	// store initial score to stack  
	
	mov	x0,	0					// x0 = 0
	str	x0,	[x29,	game_offset + game_timeCount] 	// store t_0 on stack
	
	// allocate memory for n*n array of structures size 16
	mul	alloc_r,	n_r,	n_r			// alloc = n * n
	sub	alloc_r,	xzr,	alloc_r			// alloc = - (n*n)
	lsl	alloc_r,	alloc_r, 4			// alloc = - (n*n) * 16
	and	alloc_r,	alloc_r, -16			// alloc = -(n*n)*16 & -16	
	add	sp,		sp,	alloc_r			// allocate memory for n*n array of structures

	// initialize
	sub	x0,	sp,	alloc_r				// x0 = base address
	mov	x1,	n_r					// x1 = n
	bl	init						// branch link to init
	str	x0,	[x29,	game_offset + game_timeMax]	// store timer length to stack

	// print newLine
	ldr	x0,	=newLine				// print newLine -- temp
	bl	printf						// branch link to printf
			
	// display game_board	
	sub	x0,	sp,	alloc_r				// x0 = array base address
	mov	x1,	n_r					// x1 = n
	bl	display						// branch link to display
	
	mov	quit_r,	0					// quit register = false
	mov	move_r,	0					// move counter = 0
	mov	x0,	0					// x0 = 0
	bl	time						// branch link time(0)
	mov	timer_r,x0					// timer_r = start time 
do:
	ldr	x0,	=newLine				// load address of newLine string into x0
	bl	printf						// branch link to printf
	
	ldr	x0,	=prompt					// load address of prompt string into x0
	bl	printf						// branch link to print f
	
	ldr	x0,	=fmt_in					// load address of fmt_in into x0 
	ldr	x1,	=tempVar				// load address of tempVar into x1
	bl	scanf						// branch link scanf

	ldr	temp_r,	=tempVar				// load address of tempVar into temp
	ldr	i_r,	[temp_r]				// load value of temp into i
	
	ldr	x0,	=fmt_in					// load address of fmt_in into x0
	ldr	x1,	=tempVar				// load address of tempVar inro x1
	bl	scanf						// branch link to scanf

	ldr	temp_r,	=tempVar				// load address of tempVar into temp
	ldr	j_r,	[temp_r]				// load value of tempVar into j

	sub	base_r,	sp,	alloc_r				// base address of table array
	// calculate offset				
	mul	x9,	i_r,	n_r				// offset = i * n
	add	x9,	x9,	j_r				// offset = (i * n) + j
	lsl	x9,	x9,	4				// offset = ((i * n) + j) * 16
	sub	x9,	xzr,	x9				// offset = - offset

	sub	x9,	x9,	8				// offset = -offset - 8 .... table_char

	ldr	temp_r,	[base_r, x9]				// load table[i][j].char 
	
	cmp	temp_r, 88					// if table[i][j].char != 'X'
	b.ne	while1						// branch to while1

	// update game_state
	sub	x0,	sp,	alloc_r				// x0 = table base address
	mov	x1,	n_r					// x1 = n ... dimension
	mov	x2,	i_r					// x2 = i ... player row choice
	mov	x3,	j_r					// x3 = j ... player column choice
	add	x4,	x29,	24				// game.score address
	bl	update						// branch link to update

	str	d0,	[x29,	game_offset + game_score]	// store updated score onto stack
	
	// display game board
	sub	x0,	sp,	alloc_r				// x0 = table base address
	mov	x1,	n_r					// x1 = n
	bl	display						// branch link to display

	// display score
	ldr	x0,	=score_out				// load addresss of score_out string into x0
	ldr	d0,	[x29,	game_offset + game_score]	// load score into d0 from stack
	bl	printf						// branch link printf
	

	mov	x0,	0					// x0 = 0
	bl	time						// branch link to time(0)
	sub	x9,	x0,	timer_r				// x9 = second count

	str	x9,	[x29,	game_offset + game_timeCount]	// store second count on stack

	ldr	x10,	[x29,	game_offset + game_timeMax]	// load max time from stack
	
	sub	x1,	x10,	x9				// x1 = x10 - x9
	cmp	x1,	0					// if x1 > 0
	b.lt	end						// branch to end
	// display time
	ldr	x0,	=time_out				// load address of time_out string into x0
	bl	printf						// branch link to printf

	add	move_r,	move_r,	1				// move counter ++
	b	while1						// branch to while1

while2:
	ldr	x9,	[x29,	game_offset + game_timeCount]	// load time_count from stack
	ldr	x10,	[x29,	game_offset + game_timeMax]	// load max_time from stack
	sub	x11,	x10,	x9				// x10 - x9
	cmp	x11,	0					// if (x11 > 0 )
	b.gt	do						// branch to do
	
	str 	x10,	[x29,	game_offset + game_timeCount]	// store  max_time in timeCount 
	b	end						// branch to end	
while1:
	mul	x9, 	n_r,	n_r				// x9 = max_moves
	cmp	move_r,	x9					// if(move < max_moves) 
	b.lt	while2						// branch to do
end:
	sub	alloc_r,	xzr,	alloc_r			// alloc = - alloc
	add	sp,	sp,	alloc_r				// deallocate memory

	ldp	x29,	x30,	[sp], 48			// deallocate memory		
	ret							// return

//-------------------------------------------------------- init ------------------------------------------------------------//
// x0 = table of structures base address
// x1 = n
//
// returns timer length seconds in x0

init:
	stp	x29,	x30,	[sp,	-(16 + 48) & -16]!	// allocate memory on stack
	mov	x29,	sp					// x29 = stack pointer

	stp	x19,	x20,	[x29,	16]			// store contents of x19, x20 on stack
	stp	x21,	x22,	[x29, 	32]			// store contents of x21, x22 on stack
	stp	x23,	x24,	[x29,	48]			// store contents of x23, x24 on stack

	mov	base_r,	x0					// base = x0
	mov	n_r,	x1					// n = x1

	mov	i_r,	0					// i=0
	mov	j_r,	0					// j=0
	b	test1						// branch to test1
top1:
	mov	x0,	0					// x0 = 0
	bl	random						// branch link to random with neq == 0
	fcvtns	x9,	d0					// convert result to int

	mov	x0,	0					// neg = 0

	cmp	x9,	2					// if random_num > 2, neg == 0
	b.gt	next						// branch to next
	
	mov	x0,	1					// else, neq == 1
next:
	bl	random						// branch and link random 
	
	// calculate offset				
	mul	temp_r,	i_r,	n_r				// offset = (i * n) 
	add	temp_r,	temp_r,	j_r				// offset = (i * n) + j
	lsl	temp_r,	temp_r,	4 				// offset = ((i * n) + j) * 16
	sub	temp_r,	xzr,	temp_r				// offset = -offset
	
	str	d0,	[base_r, temp_r]			// store result of random on stack
		
	sub	temp_r,	temp_r,	8				// shift offset by 8 
	mov	x0,	88					// x0 = 'X'
	str	x0,	[base_r, temp_r]			// store on stack
	
	add	j_r,	j_r,	1				// j++	
test2:
	cmp	j_r,	n_r					// if(j<n)
	b.lt	top1						// branch to top1

	mov	j_r,	0					// j=0
	add	i_r,	i_r,	1				// i++
test1:
	cmp	i_r,	n_r					// if (i<n)		
	b.lt	test2						// branch to test2

	mul	x9,	n_r,	n_r				// x9 = n*n
	add	x9,	x9,	n_r				// x9 = n*n + n
	lsl	x9,	x9,	1				// x9 = (n * n + n) * 2 ... n = 5 => x9 = 60s
	mov	x0,	x9					// x0 = timer length 

	ldp	x19,	x20,	[x29, 16]			// restore x19, x20 from stack
	ldp	x21,	x22,	[x29, 32]			// restore x21, x22 from stack
	ldp	x23, 	x24,	[x29, 48]			// restore x23, x24 from stack
	ldp	x29,	x30,	[sp], 64			// deallocate memory
	ret							// return 

// ------------------------------------------------------------ display ----------------------------------------------------------- //
display:							
	stp	x29,	x30,	[sp, -(16 + 32) & -16]!		// allocate memory
	mov	x29,	sp					// x29 = sp

	stp	x19,	x20,	[x29, 16]			// store contents of x19, x20 on stack 
	stp	x21,	x23,	[x29, 16 + 16]			// store contents of x21, x23 on stack 

	mov	i_r,	0					// i = 0
	mov	j_r,	0					// j = 0

	mov	base_r,	x0					// table structure base address
	mov	n_r,	x1					// move x1 into n register

	b	test3						// branch to test3
top2:
	mul	x9,	i_r,	n_r				// offset = i * n
	add	x9,	x9,	j_r				// offset = (i * n) + j
	lsl	x9,	x9,	4				// offset = ((i * n) + j) * 16 ... struct size 
	sub	x9,	xzr,	x9				// offset = -offset

	sub	x9,	x9,	8				// offset = -offset - 8 bytes 
	
	ldr	x1,	[base_r, x9]				// load character value from stack
	ldr	x0,	=char_out				// load address of char_out string into x0
	bl	printf						// branch link to printf

	add	j_r,	j_r,	1				// j++
test4:
	cmp	j_r,	n_r					// if(j<n)
	b.lt	top2						// branch to top2

	ldr	x0,	=newLine				// load address of newLine string into x0
	bl	printf						// branch link to printf
	
	add	i_r,	i_r, 	1				// i++
	mov	j_r,	0					// j=0
test3:
	cmp	i_r,	n_r					// if(i<n)	
	b.lt	test4						// branch to test4
		
	ldr	x0,	=newLine				// load address of newLine string into x0
	bl	printf						// branch link to printf

	ldp	x19,	x20,	[x29, 16]			// restore x19, x20 from stack
	ldp	x21,	x23,	[x29, 16 + 16]			// restore x21, x22 from stack
	ldp	x29,	x30,	[sp], 48			// deallocate memory 
	ret							// return

// ------------------------------------------------------------- random --------------------------------------------------------------- //

random:
	stp	x29,	x30,	[sp, -(16 + 32) & -16]!		// allocate memory
	mov	x29,	sp					// x29 = sp
						
	stp	x19,	x20,	[x29, 16]			// store contents of x19, x20 on stack 
	stp	x21,	x22,	[x29, 16 + 16]			// store contents of x21, x22 on stack

	mov	x22,	x0					// x22 = neg register
	
	bl	rand						// branch link to rand()
	mov	x19,	x0					// x19 = rand()
				
	mov	x9,	0x5db					// x9 = 1499
	and	x19,	x19,	x9				// x19 = rand() & 1499 
		
	mov	x20,	100					// x20 = 100
	
	scvtf	d0,	x19					// d0 = (float) x19 
	scvtf	d1,	x20					// d1 = 100.00
	fdiv	d0,	d0,	d1				// d0 = random, random float between 0 and 14.99
		
	cmp	x22,	0					// if neg == false
	b.eq	pos						// branch to positive
						
	fneg	d0,	d0					// else. float negate.
pos:
	ldp	x19,	x20,	[x29, 16]			// restore x19, x20 from stack
	ldp	x21,	x22,	[x29, 16 + 16]			// restore x21, x22 from stack
	ldp	x29,	x30,	[sp], 48			// deallocate memory
	ret							// return random float

// ------------------------------------------------------------- update ---------------------------------------------------------------- //
// TODO: Update Score & Time
// returns updated score in d0
// returns updated time in x0

update:
	stp	x29,	x30,	[sp, -(16 + 48) & -16]!		// allocate memory on stack
	mov	x29,	sp					// x29 = sp

	stp	x19,	x20,	[x29, 16]			// store contents of x19, x20 on stack
	stp	x21,	x22,	[x29, 32]			// store contents of x21, x22 on stack
	stp	x23,	x24,	[x29, 48]			// store contents of x23, x24 on stack

	mov	base_r,	x0					// base address of table of structures 
	mov	n_r,	x1					// n = x1	
	mov	i_r,	x2					// i = x2
	mov	j_r,	x3					// j = x3
	ldr	d20,	[x4]					// load value of total score from stack into d20

	mul	x9,	i_r,	n_r				// offset = i*n 
	add	x9,	x9,	j_r				// offset = (i * n) + j
	lsl	x9,	x9,	4				// offset = ((i * n) + j) * 16
	sub	x9,	xzr,	x9				// offset = -offset
	
	mov	temp_r,	x9					// temp = offset
	sub	temp_r,	temp_r,	8				// shift offset 8 bytes. points to character 

	ldr	d0,	[base_r, x9] 				// load turn score from stack
	
	fmov	d19,	d0					// move turn score into d19

	// reward
	fmov	d9,	1.0					// d9 = 1.0
	fcmp	d19,	d9					// if (score > 1.0)
	b.gt	case1						// branch to case1
	
	// bomb 
	fneg	d9,	d9					// d9 = -1.0
	fcmp	d19,	d9					// if (score < -1.0)
	b.lt	case2						// branch to case2
	
	// double score
	fcmp	d19,	0					// if (1 > score > 0) 
	b.gt	case3						// branch to case3

	// half score 
	mov	x9,	33					// x9 = '!'
	str	x9,	[base_r, temp_r]			// store '!' to stack

	ldr	x0,	=message4				// load address of message4 string into x0
	bl	printf						// branch link to printf
	
	fcvtns	x10,	d20					// convert total score to integer 
	lsr	x10,	x10,  	1				// logical shift right .. divide by 2
	scvtf	d0,	x10					// convert to float
	
	b	break						// branch to break
case3:
	mov	x9,	36					// x9 = '$'
	str	x9,	[base_r, temp_r]			// store '$' to stack
	ldr	x0,	=message3				// load address of message3 string into x0
	bl	printf						// branch link printf

	fcvtns	x10,	d20					// convert total score to integer
	lsl	x10,	x10,	1				// logical shift left .. mult 2
	scvtf	d0,	x10					// convert to float

	b	break						// branch to break
case2:
	mov	x9,	45					// x9 = '-'
	str	x9,	[base_r, temp_r]			// store '-' to stack

	ldr	x0,	=message2				// load address of message2 string into x0
	fmov	d0,	d19					// d0 = turn score
	bl	printf						// branch link to printf

	fadd	d0,	d20,	d19				// update total score 
	b	break						// branch to break
case1:
	mov	x9,	43					// x9 = '+'
	str	x9,	[base_r, temp_r]			// store '+' to stack

	ldr	x0,	=message1				// load address of message1 string into x0
	fmov	d0,	d19					// d0 = turn score
	bl	printf						// branch link to printf
	
	fadd	d0,	d20,	d19				// update total score
	b	break						// branch to break
break:							
	ldp	x19,	x20,	[x29, 16]			// restore x19, x20 from stack
	ldp	x21,	x22,	[x29, 32]			// restore x21, x22 from stack
	ldp	x23,	x24,	[x29, 48]			// restore x23, x24 from stack
	ldp	x29,	x30,	[sp], 64			// deallocate memory
	ret							// return d0

		.data
tempVar:	.word	0

























