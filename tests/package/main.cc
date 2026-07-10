#include <serial/serial.h>

int main()
{
  serial::Timeout timeout = serial::Timeout::simpleTimeout(1000);
  return timeout.read_timeout_constant == 1000 ? 0 : 1;
}
