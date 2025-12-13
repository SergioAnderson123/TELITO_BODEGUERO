// ===================== Modal de Enviar Productos por Correo =====================
const sendEmailModalProductos = document.getElementById('sendEmailProductosModal');
const openSendEmailBtnProductos = document.getElementById('openSendEmailModalProductos');
const closeSendEmailBtnProductos = sendEmailModalProductos.querySelector('.modal-close');
const cancelSendEmailBtnProductos = sendEmailModalProductos.querySelector('.modal-cancel-productos');

function abrirModalEnviarProductos() {
    sendEmailModalProductos.classList.add('show');
    sendEmailModalProductos.style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

function cerrarModalEnviarProductos() {
    sendEmailModalProductos.classList.remove('show');
    sendEmailModalProductos.style.display = 'none';
    document.body.style.overflow = '';
}

if (openSendEmailBtnProductos) {
    openSendEmailBtnProductos.addEventListener('click', abrirModalEnviarProductos);
}

if (closeSendEmailBtnProductos) {
    closeSendEmailBtnProductos.addEventListener('click', cerrarModalEnviarProductos);
}

if (cancelSendEmailBtnProductos) {
    cancelSendEmailBtnProductos.addEventListener('click', cerrarModalEnviarProductos);
}

if (sendEmailModalProductos) {
    sendEmailModalProductos.addEventListener('click', function(event) {
        if (event.target === sendEmailModalProductos) {
            cerrarModalEnviarProductos();
        }
    });
}
