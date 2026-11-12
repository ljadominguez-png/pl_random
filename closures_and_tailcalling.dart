//create a function that throws 3 arguments with closure
Function adDandSum(int first, int second, int third) {
  if (first > 0) {
    print('Numbers: $first, $second, $third');
    //closure using lambda
    return () => adDandSum(first - 1, second, third);
  }
  // final output
  return adDandSum;
}

void main() {
  var step1 = adDandSum(5, 4, 3);
  var step2 = step1();
  var done = step2;
}
