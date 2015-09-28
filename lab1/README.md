
# Information Security Lab 1.

### Cryptographic Hashes

Hash functions are a special class of so called one-way functions, that are relatively easy to compute in one direction while the other way around their computation is more or less infeasible, depending on the available computational power. Moreover a good hash function should have a very low probability of collision, i.e. a situation when for two different inputs it gives the same output.

These functions are widely used in Computer Science and especially in the fields that are concerned with information security. The simplest example is how passwords are stored in a database. Actually the point in this is that the hashes of passwords are stored instead of the passwords themselves, and when there is a need to compare two passwords, their hashes are compared. This means that a breach in the database wouldn't disclose the passwords of users and wouldn't provide access to personal information to the person who caused the breach.

Besides security, hash functions are used for integrity checks. Suppose there is a large file and it is necessary to find out if there were any changes in this file after some time. One way to do this is to store a snapshot of this file and after some time compare the current file with the snapshot created before. This procedure is rather expensive in terms of space that is used to store the snapshot as well as computing time that is required to compare two large blobs of data. Instead, it is possible to compute the hash of the original, store it and then compare to the hash of a later version of the file.


### Directory Checker

This laboratory work is meant to illustrate the later use-case of cryptographic hashes. The concept is rather simple, the program is required to detect changes in files that are located under a certain path, and it should do it by using hash functions.


##### The working principle
  - the program scans the paths of all files that are located under the path that was passed to the program as an argument
  - it computes the hashes of each file and stores the 'hash-path' pairs in a file `PATH/.dircheck`, where the `PATH` is the one that was passed to the program
  - on subsequent executions the program reads the contents of the file and compares them with the freshly computed 'hash-path' pairs.
  - the process can be controlled using some flags and parameters passed to the program as additional command line arguments. This includes skipping files that match a certain pattern as well as those that are larger than a certain amount of bytes.


##### Usage
```
$ dircheck -h
Usage: dircheck PATH [options]
    -s, --silent                     Suppress output if no changes are found.
    -e, --exclude x,y,z              Exclude file extensions.
    -M, --maxsize INTEGER            Specify maximum file size to consider.
```


##### Algorithms

The hashing algorithm used for this app is MD5 because it is faster than SHA-1 or SHA-256 and there is no need for the high level of security that the later algorithms provide. Moreover, CRC32 algorithm could also be successfully used for this task as its specific purpose is integrity checking and it works at high speeds.


##### Large files

The requirements for the laboratory work stated that it is necessary to take into account that some files might be too large to fit into memory and the program should do something about it. As it turns out Ruby has the right tools to get around this problem, and specifically the `Digest::Class::file` method. As opposed to `Digest::Class::hexdigest` it doesn't take a string as an input, instead, it receives a path to a file and returns an object on which it is possible to call the `hexdigest` method which would cause the file to be read and processed in chunks.


### Scheduled job

In order to perform a check on the folder every minute, the following crontab was used:
```
* * * * * echo '---' >> ~/.dircheck_log && /usr/local/bin/dircheck ~/code/infosec/ -s -e "*.tmp" -M 1000 >> ~/.dircheck_log$
```


### Final thoughts

The application performs pretty well on folders with small amounts of files. It is not yet tested on large file trees and big files. Probably there is a more efficient way to store the hashes for all files like a sqlite3 database (as stated in lab recommendations). It would add support for path indexing and would provide easier means for storing the history of file changes. On the other hand, simple file storage does its job for now, plus the application is free of external dependencies.
