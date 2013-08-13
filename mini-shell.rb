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

    pid = fork {
      command, *args = Shellwords.shellsplit(input)
      exec(command, *args)
    }

    Process.wait(pid)
  end
end

