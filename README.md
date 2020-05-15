# CPSC 355 Assignment 1 - TableSort

## Usage

```bash
gcc assign1.c -o tableSort.o
./tableSort.o N
```
Where N is an integer value specifying dimension of random matrix.

## Sorting Algorithm
```c
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
```

This implementation of sort takes pointer for table[][] as parameter. Iterating through each element of sort_column and comparing values. Using the fact that
```c
*(table + i * num_cols + k) = table[i][k]
```
Then if 
```c
table[i][k] > table[j][k] 
```
the rows of the matrix are swapped through reference. This is repeated for each element of the selected column. 
