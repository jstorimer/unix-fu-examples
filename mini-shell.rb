require 'readline'
require 'shellwords'

BUILTINS = {
  'exit' => -> { exit },
  'cd' => Proc.new { |dir| Dir.chdir(dir) }
}

while input = Readline.readline("$ ") do
  program, *args = Shellwords.split(input)

  if BUILTINS.has_key?(program)
    BUILTINS[program].call(*args)

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
      exec(program, *args)
    }

    Process.wait(pid)
  end
end

