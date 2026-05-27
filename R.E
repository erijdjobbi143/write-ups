today we’ll be solving a  simple reverse engineering chalenge on pwn.college, you can access the challenge through this link:
https://pwn.college/intro-to-cybersecurity/reverse-engineering/
we’ll start by checking the existing files on the directrory /challenge:

```bash
hacker@reverse-engineering~file-formats-magic-numbers-c:~$ cd /challenge
hacker@reverse-engineering~file-formats-magic-numbers-c:/challenge$ ls
DESCRIPTION.md  cimg  cimg.c
```
we notice that we have 2 files (DESCRIPTION.md is just the description of challenge you can  read it if you want)
-cimg.c which is a c code file in a txt format
-cimg which is an ELF (Extensible Linking Format)
note: you can get extra informations about the files by using exiftool

so we’ll start by trying to execute the binary, but unfortunately we got an error, and  it was expected bcz if we look at the files permissions by using exiftool we notices that the executable permission is denied.
we’ll try to modify the permissions and see what happens:

```bash
hacker@reverse-engineering~file-formats-magic-numbers-c:/challenge$ chmod +x cimg
chmod: changing permissions of 'cimg': Operation not permitted
```
                                
it didn’t work either....
let’s check the c code maybe it can help
so by reading the c code we can get many helpful information. In fact  it checks many things and have many conditions..but if we focus more on the main function , we can notice that “winning the flag” depends only on the header check

```c
int main(int argc, char **argv, char **envp)
{

    struct cimg cimg = { 0 };
    int won = 1;

    if (argc > 1)
    {
        if (strcmp(argv[1]+strlen(argv[1])-5, ".cimg"))
        {
            printf("ERROR: Invalid file extension!");
            exit(-1);
        }
        dup2(open(argv[1], O_RDONLY), 0);
    }

    read_exact(0, &cimg.header, sizeof(cimg.header), "ERROR: Failed to read header!", -1);

    if (cimg.header.magic_number[0] != '{' || cimg.header.magic_number[1] != 'O' || cimg.header.magic_number[2] != 'n' || cimg.header.magic_number[3] != 'r')
    {
        puts("ERROR: Invalid magic number!");
        exit(-1);
    }

    if (won) win();
  ```
In fact, won=1 always and it’s never modified anywhere. All we need to do is to pass the header checker by providing the write input which is ,as we can see, “{Onr”
We’lll pass “{Onr” as an output and execute the binary:
              
```bash
hacker@reverse-engineering~file-formats-magic-numbers-c:/challenge$ printf '{Onr' | ./cimg
pwn.college{gVoqPyql2ALz00pOXLvM2chObn7.0lNwUjNxwSN0ATM2EzW}
```

TADAAA we got the flag
so we can conclude that the vulnerability is a logic flaw caused by the variable won being initialized to 1 and never modified, making the condition if (won) always true and allowing direct access to win() after passing the magic number check.              


                                '
