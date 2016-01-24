
# Information Security Lab 2.

### Hacking challenge


#### Objective

Given a remote machine, it is necessary to gain as much access to it as possible. All that is known before hand is a domain name that resolves to the machine's IP address, the fact that an SSHD service is running and there is a user called `level1`.


#### Finding The Right Port

After the first attempt to ssh `level1@domain2hack` it was clear that the daemon runs on a non-standard port. To determine the correct port number, the `nmap` unix tool was used.

As a result of a port scan it was identified that there are a couple open TCP ports on the machine, and after trying to connect to each one of them, the port `724` was found to be serving ssh connections.


#### Levels 1,2,3

The first three levels didn't require any special tools to be cracked as all the hints indicated that the passwords are among the most commonly used weak passwords. The password for the first level turned out to be the user name itself. For the second and the third one, using the method of trial and error, the passwords where found in different charts of most popular passwords ever used.


#### Level 4

The hint for level 4 stated that the password was a common English word, at this step it was clear that an automated approach was necessary. Several brute-force applications like `hydra` and `medusa` were tried but they proved to be unreliable as they sometimes failed to crack the level to which the answer was already known.

The situation demanded a custom solution.
The following Ruby script was used to perform dictionary and brute-force attacks for this and the following levels:

```ruby
passwords_file = ARGV[1] || 'words.txt'

passwords = File.read(passwords_file).lines.map(&:chomp) - File.read("checked.txt").lines.map(&:chomp)
passwords.shuffle!

user = ARGV[0]
host = 'domain2hack'
port = 724

puts "Trying to hack ssh://#{user}@#{host}:#{port} with passwords from #{passwords_file}"

checked = File.open('checked.txt', 'a')

Parallel.each(passwords, progress: "Processing", in_threads: 20) do |pass|
  begin
    session = Net::SSH.start(
      host,
      user,
      password: pass,
      port: port,
      non_interactive: true,
      number_of_password_prompts: 0
    ) do |ssh|
      result = "#{Time.now} -- #{user} -- #{pass}"
      File.open('results.txt', "a") {|f| f.puts result }
      # send_pass(pass) # used to send email on success
      puts result
      raise Parallel::Kill
    end

  rescue Parallel::Kill
    raise
  rescue Net::SSH::AuthenticationFailed
    checked.puts pass
  rescue Exception
    sleep rand
    retry
  end
end

checked.close
```

The code above makes parallel attempts to connect to the server and retries unless a an `AuthenticationFailed` error happens or the right password is found. This way the script will retry a password if a connection cannot be established due to a failure in the network.

The word pool was taken from the American dictionary found in every Ubuntu distribution (`/usr/share/dict/american-english`) and it took about 8 hours to find the right password.


#### Level 5

Finding the fifth password consisted of generating a list of all possible combinations of 5 latin lowercase characters. It turned out that the performance of the Ruby script was not quite enough to check 12000000 passwords in a reasonable period of time. Moreover, the server was under heavy load from other people also trying to hack it.

A new approach was necessary. A good observation was made about the fact that the greatest bottle-neck in the whole process was the network, so why not host the script on the remote machine itself (the access was already granted to lower levels and it turned out that the users could execute arbitrary scripts).

A portable version of the script was devised and uploaded and tested with success on already cracked levels with a great improvement in speed. In the process it was identified that an ssh brute force attack could be replaced with a 'switch user' attack. So it happened that a working tool just for that already existed called [`sucrack`](https://labs.portcullis.co.uk/tools/sucrack/). Switching to `sucrack` gave an impressive boost in performance, this permitted a faster check on large dictionaries of passwords.

#### Level 5a

This level required a bit more then just brute force. The hint stated that the password is the name of a music artist that our teacher likes. To crack this level, the power of social networks was leveraged, specifically the Facebook and Last.fm accounts. By collecting all music-related names, a rather small dictionary was obtained and it yielded a result pretty soon.


#### Level 6

Level 6 was one of the simplest given the experience of previous levels, as the hint indicated that the dictionary is quite small and can be generated easily without additional external information.


#### Levels 5b, 5c

These levels remained unsolved because they required more profound social-engineering skills and the dictionary that had to be generated had ambiguous rules to it.


#### Conclusion

This assignment was arguably the most addictive challenge of all four years of the university. It gave us some perspective on the strength of passwords that happen to be used in the real world and it has also put us in the situation to review our own passwords.



