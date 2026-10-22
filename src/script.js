const API_KEY = "SUA_CHAVE_AQUI"; 

// 1. Busca tarefas do banco de dados
fetch('db.json')
    .then(response => {
        if (!response.ok) throw new Error('Falha ao carregar os dados');
        return response.json();
    })
    .then(data => {
        document.getElementById('db-status').textContent = data.status;

        const list = document.getElementById('task-list');
        data.itens.forEach(item => {
            const li = document.createElement('li');
            li.textContent = item.task;
            list.appendChild(li);
        });
    })
    .catch(err => {
        console.error('Erro detalhado:', err);
        document.getElementById('db-status').textContent = 'Erro ao carregar as tarefas. Tente novamente mais tarde.';
    });

// 2. Adiciona nova tarefa
function addTask() {
    const input = document.getElementById('new-task');
    const output = document.getElementById('output');

    const taskText = input.value.trim();
    if (!taskText) return;

    // Criação segura do elemento DOM
    const li = document.createElement('li');
    li.textContent = taskText;
    
    output.appendChild(li);

    console.log("Tarefa adicionada: " + taskText);

    input.value = '';
}