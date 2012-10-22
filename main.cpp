#include <cstdlib>

using namespace std;

int readsa()
{
  for (int j = 0; j < length_CA / 2; j++) // length_CA = CA - 1 int
  {
    if ((i >= CA[j * 2]) && (i < CA[j * 2 + 1] + CA[j * 2]))
      Put 1 in EBP;
  }
  
  Put 0 in EBP;
}

void writesa()
{
  if (readsa(request index) = write value)
  {
    Dont do anything.
  }
  else if (index = 0)
  {
    if (write value = 1)
    {
      if (checkRight() = 0)
      {
        l_CA += 2;
        shiftRight();
        CA[0] = 0;
        CA[1] = 1;
      } 
      else if (checkRIght() = 1)
      {
        CA[0] = 0;
        CA[1]++;
      }
    }
    else if (write value = 0)
    {
      if (checkRight() = 0)
      {
        shiftLeft();
      } 
      else if (checkRIght() = 1)
      {
        CA[0] = 1;
        CA[1]--;
      }
    }
  }
  else if (index = l_UA - 1)
  {
    if (write value = 1)
    {
      if (checkLeft() = 0)
      {
        l_CA++;
        CA[l_CA - 2] = l_UA - 1;
        CA[l_CA - 1] = 1;
      }
      else if (checkLeft() = 1)
      {
        CA[L_CA - 1]++;
      }
    }
    else if (write value = 0)
    {
      if (checkLeft() = 0)
      {
        l_CA -= 2;
      }
      else if (checkLeft() = 1)
      {
        CA[l_CA - 1]--;
      }
    }
  }
  else
  {
    if (write value = 1)
    {
      if(checkLeft() = checkRight())
      {
        if (checkLeft() = 0)
        {
          l_CA += 2;
          iCA = whereAmI();
          shiftRight(iCA);
          CA[iCA] = index;
          CA[iCA + 1] = 1;
        }
        else if (checkLeft() = 1)
        {
          iCA = whereAmI();
          CA[iCA - 1] += CA[iCA +1] + 1;
          shiftLeft(iCA + 2);
          l_CA -= 2;
        }
      }
      else if (checkLeft() = 0 && checkRight() = 1)
      {
        iCA = whereAmI();
        CA[iCA]--;
        CA[iCA + 1]++;
      }
      else if (checkLeft() = 1 && checkRight() = 0)
      {
        iCA = whereAmI();
        CA[iCA - 1]++;
      }
    } //end of write value = 1
    else if (write value = 0)
    {
      if(checkLeft() = checkRight())
      {
        if (checkLeft() = 0)
        {
          iCA = whereAmI();
          shiftLeft(iCA);
          l_CA -= 2;
        }
        else if (checkLeft() = 1)
        {
          l_CA += 2;
          iCA = whereAmI();
          shiftRight(iCA);
          temp = CA[iCA - 1] + CA[iCA - 2];
          CA[iCA - 1] = index - 1 - CA[iCA - 2];
          CA[iCA] = index + 1;
          CA[iCA + 1] = temp - CA[iCA];
        }
      }
      else if (checkLeft() = 0 && checkRight() = 1)
      {
        iCA = whereAmI();
        CA[iCA]++;
        CA[iCA + 1]--;
      }
      else if (checkLeft() = 1 && checkRight() = 0)
      {
        iCA = whereAmI();
        CA[iCA - 1]--;
      }
    }
  }
}

void shiftRight(index)
{
  for (int i = l_CA; i >= index; i--)
  {
    CA[i+2] = CA[i];
  }
}

void shiftLeft(index)
{
  
}

int main(int argc, char** argv) {

  return 0;
}

