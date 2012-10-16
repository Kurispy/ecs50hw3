#include <cstdlib>

using namespace std;

int readsa(int length, int i)
{
  for (int j = 0; j < length_CA / 2; j++) // length_CA = CA - 1 int
  {
    if ((i >= CA[j * 2]) && (i < CA[j * 2 + 1] + CA[j * 2]))
      Put 1 in EBP;
  }
  
  Put 0 in EBP;
}

int main(int argc, char** argv) {

  return 0;
}

