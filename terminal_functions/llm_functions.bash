

function chat (){

  local input_text

  echo "

   $(figlet 'LLM Chat' -f slant)

   Bem-vindo ao chat CLI.

    Eu sou um assistente de IA projetado para ajudar com tarefas de engenharia de software diretamente no seu terminal. Você pode me pedir para executar comandos, ler ou escrever arquivos, pesquisar na sua base de codigo e muito mais.
    Fui feito para consultas pontuais e diretas.
    Interaja comigo como faria com um colega de equipe experiente, fornecendo instruções claras para tarefas especificas.

    por exemplo
    * Como eu transformo datetime para date em python
    * Como eu saio do Vim
    * me de uma receita de bolo de chocolate


    --> para sair do chat digite exit no prompt


  " > "/tmp/llm_intro.md"
  temp_file="/tmp/llm_intro.md"


  while true; do
    clear
    input_text=$( echo "" | fzf --tmux --info hidden --preview-window=up:99% --height 90%  --print-query --prompt="> " --preview "batcat -p --color=always ${temp_file}")

    if [[ "$input_text" == "exit" ]]; then
      break
    fi

    rm -f "${temp_file}"
    temp_file="$(mktemp).md"
    echo "Pensando...."
    gemini --model gemini-2.5-flash --prompt "apenas me retorne texto não faça nenhuma sugestao de criacao de arquivo ou alteração se for trecho de codigo formate  
    o codigo como snippet de arquivos de marcaoção do prompt asseguir responda no mesmo idioma do prompt porem todo codigo gerado precisa ser em ingles : ${input_text}" > $temp_file

    cat $temp_file | clip.exe

    echo # Adiciona uma linha em branco para melhor legibilidade
  done
  

}
