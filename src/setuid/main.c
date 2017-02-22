#include <unistd.h>

int main(int argc, char ** argv)
{
    uid_t olduid = getuid();
    gid_t oldgid = getgid();

    setuid(0);
    setgid(0);

    int result = execv(argv[1], &argv[1]);

    setuid(olduid);
    setgid(oldgid);

    return result;
}
