#include <iostream>
using namespace std;

int main() 
{
    int array[] = {-60, 5, -10, 3, -2, 1, 99, 442, -9, -43, 0};
    int array_len = sizeof(array) / sizeof(array[0]);

    int max_val_idx = 0;
    int min_val_idx = 0;
    int max_val = array[max_val_idx];
    int min_val = array[min_val_idx];
    
    for (int i = 0; i < (array_len - 1); i++)
    {
        if (array[i] < min_val)
        {
            min_val_idx = i;
            min_val = array[i];
        }
        if (array[i] > max_val)
        {
            max_val_idx = i;
            max_val = array[i];
        }
    }
    int result = 0;

    int start_idx = min_val_idx < max_val_idx ? min_val_idx : max_val_idx;
    int end_idx =  max_val_idx > min_val_idx ? max_val_idx : min_val_idx;
    for (int i = start_idx+1; i < end_idx+1; i++)
    {
        if (array[i] < 0)
        {
            result += array[i];
        }
    }

    cout << "Sum = " << result << endl;
    return 0;
}
