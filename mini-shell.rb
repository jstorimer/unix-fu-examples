require 'readline'
require 'shellwords'

BUILTINS = {
  'exit' => -> { exit },
  'cd'   => ->(dir) { Dir.chdir(dir) },
  'exec' => ->(cmd) { exec(cmd) }
}

while input = Readline.readline("$ ") do

  if BUILTINS.has_key?(input)
    BUILTINS[input].call

  else
    commands = input.split("|")
    # ["ls", "grep md"]
    
    # Exercise
    # ========
    # Assuming that you have two commands connected by a pipe,
    # how would you spawn them both and hook up the pipeline?
    #
    # $ ls | grep md
    
#    rd, wr = IO.pipe
#
#    # ls
#    pid = fork {
#      rd.close
#      $stdout.reopen(wr)
#
#      program, *args = Shellwords.split(commands[0])
#      exec(program, *args)
#    }
#
#    # grep
#    pid = fork {
#      wr.close
#      $stdin.reopen(rd)
#
#      program, *args = Shellwords.split(commands[1])
#      exec(program, *args)
#    }
#
#    rd.close
#    wr.close
#    Process.waitall
   
    # 
    # Bonus challenge
    # ===============
    # Assuming that you have N commands connected in a pipeline,
    # how would you spawn them all and hook up pipes between them?
    #
    # $ ls | grep md | wc -c | pbcopy
   
    next_stdout = $stdout
    next_stdin = $stdin
    
    commands.each_with_index do |command, index|
      if index+1 == commands.size # the last command
        next_stdout = $stdout
      else
        reader, writer = IO.pipe
        next_stdout = writer
      end

      pid = fork {
        $stdout.reopen(next_stdout)
        $stdin.reopen(next_stdin)

        program, *args = Shellwords.split(command)
        exec(program, *args)
      }

      next_stdout.close unless next_stdout == $stdout
      next_stdin.close unless next_stdin == $stdin

      next_stdin = reader
    end

    Process.waitall
  end
end

