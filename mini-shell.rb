require 'readline'
require 'shellwords'

BUILTINS = {
  'exit' => -> { exit }
  #'cd' => -> { |dir| Dir.chdir(dir) }
}

while input = Readline.readline("$ ") do
  if BUILTINS[input]
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
    

   
    # 
    # Bonus challenge
    # ===============
    # Assuming that you have N commands connected in a pipeline,
    # how would you spawn them all and hook up pipes between them?
    #
    # $ ls | grep md | wc -c | pbcopy
    #
    # ls(grep('md', wc(pbcopy))))
    #
    # ls 
    # grep
    # wc
    # pbcopy
    
    #
    # ls(30)
    # ls grep wc pbcopy
    
    next_stdout = $stdout
    next_stdin = $stdin

    commands.each_with_index do |command, index|
      if index+1 == commands.size
        # if this is the last command
        next_stdout = $stdout
      else
        reader, writer = IO.pipe
        next_stdout = writer
      end
    
      pid = fork {
        $stdin.reopen(next_stdin)
        $stdout.reopen(next_stdout)

        program, *args = Shellwords.shellsplit(command)
        exec(program, *args)
      }

      next_stdout.close unless next_stdout == $stdout
      next_stdin.close unless next_stdin == $stdin
      
      next_stdin = reader
    end

    Process.waitall
  end
end

