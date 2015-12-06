
# Information Security Lab 4.

### Computer Forensics Challenge

#### The Task

Given an image of a formatted SD card, it is necessary to recover as much infromation as possible about the owner of this flash memory card.

#### File Carving

To recover information from the provided image file, the `photorec` program was used. As a result of experimenting with different settings, it was possible to recover about one hundred different files. To be specific, here are some stats:

- 28 plain text files
- 2 PNG images
- 34 JPEG images
- 15 MP3 files
- 1 corrupteg RAR archive
- 2 PKCS#12 containers
- 2 XLS spreadsheets
- 4 PDF documents
- 5 DOC documents


#### File Inspection

The audio files seem to belong to an audio-book or a course of audio-lessons.

The plain text files contain some kind of source code, probably the owner of the flash card has something to do with programming. A couple of PDF and DOC files lead to the conclusion that this person teaches a course of Information Security and one of Networks at the Technical University of Moldova and apparently his name is _Alex Railean_.

Among the 34 JPEG images mentioned above, there are pictures of 2 men, and a woman. It is not clear, however, who of them is Alex Railean. The majority of the photos where taken with a `Cannon PowerShot A550` photo-camera. Two photos are taken using a `Canon PowerShot SX230 HS` camera and contain GPS data that points to locations in the state of Washington, United States.

#### Cracking PKCS 12 Archives

The two .pfx files found on the image, turned out to be protected with a password. A quick search on the internet returned a program for cracking passwords of this kind of files. To estimate the cracking speed, a brute-force attack was started, using only passwords that contain 5 characters (lower-case lating letters and numbers). As a matter of fact this resulted in finding the password, which by coincidence was also composed of 5 symbols.

The password made it possible to open both .pfx files. These in turn, contained a series of X.509 certificates issued to the same Alex Railean mentioned above. The certificates also contained such information as Alex's email and the address of the company that issued the certificates. Most probably Alex is an employee of this company (Dekart).


### Entropy Visualizer

The alternative task was to implement a visualizer for the level of entropy in a file. The solution presented here analyzes blocks of bytes and prints to the console the [_Shannon Entropy_](http://www.bearcave.com/misl/misl_tech/wavelets/compression/shannon.html) for every given block presented as a colored cell.

The tool is a Ruby script and accepts 3 arguments:

- **size** of a block in bytes
- **offset** from the begining of the file (optional)
- **limit** or total amount of bytes to be processed (optional)

```bash
$ ./entropy.rb 512 1234 5000
```

Command line arguments give the possibility to examine specific sectors of a file as well as the detalization.

![Screenshot](https://raw.githubusercontent.com/Andreis13/infosec/master/lab4/entropy_visualizer/screen.png)
