<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
    Componente de Modales Personalizados
    Reemplaza los alerts y confirms nativos del navegador
--%>

<!-- Modal de Alerta -->
<div class="modal fade" id="customAlertModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title d-flex align-items-center" id="customAlertTitle">
                    <i class="fas fa-info-circle me-2 text-info" id="customAlertIcon"></i>
                    <span id="customAlertTitleText">Información</span>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="customAlertMessage" class="mb-0"></p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">
                    <i class="fas fa-check me-1"></i> Entendido
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal de Confirmación -->
<div class="modal fade" id="customConfirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title d-flex align-items-center">
                    <i class="fas fa-question-circle me-2 text-warning"></i>
                    <span id="customConfirmTitle">Confirmar acción</span>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="customConfirmMessage" class="mb-0"></p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-times me-1"></i> Cancelar
                </button>
                <button type="button" class="btn btn-primary" id="customConfirmBtn">
                    <i class="fas fa-check me-1"></i> Aceptar
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal de Éxito -->
<div class="modal fade" id="customSuccessModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0 bg-success text-white">
                <h5 class="modal-title d-flex align-items-center">
                    <i class="fas fa-check-circle me-2"></i>
                    <span>¡Éxito!</span>
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="customSuccessMessage" class="mb-0"></p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-success" data-bs-dismiss="modal">
                    <i class="fas fa-check me-1"></i> Aceptar
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal de Error -->
<div class="modal fade" id="customErrorModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0 bg-danger text-white">
                <h5 class="modal-title d-flex align-items-center">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <span>Error</span>
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="customErrorMessage" class="mb-0"></p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-danger" data-bs-dismiss="modal">
                    <i class="fas fa-times me-1"></i> Cerrar
                </button>
            </div>
        </div>
    </div>
</div>

<style>
    .modal-content {
        border-radius: 15px;
        overflow: hidden;
    }
    .modal-header {
        padding: 1.5rem;
    }
    .modal-body {
        padding: 1.5rem;
        font-size: 1rem;
    }
    .modal-footer {
        padding: 1rem 1.5rem;
    }
</style>

<script>
    // Variables globales para las instancias de modales (reutilización)
    let alertModalInstance = null;
    let confirmModalInstance = null;
    let successModalInstance = null;
    let errorModalInstance = null;
    
    // Función para obtener o crear instancia del modal de alerta
    function getAlertModal() {
        if (!alertModalInstance) {
            const modalElement = document.getElementById('customAlertModal');
            alertModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        }
        return alertModalInstance;
    }
    
    // Función para obtener o crear instancia del modal de confirmación
    function getConfirmModal() {
        if (!confirmModalInstance) {
            const modalElement = document.getElementById('customConfirmModal');
            confirmModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        }
        return confirmModalInstance;
    }
    
    // Función para obtener o crear instancia del modal de éxito
    function getSuccessModal() {
        if (!successModalInstance) {
            const modalElement = document.getElementById('customSuccessModal');
            successModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        }
        return successModalInstance;
    }
    
    // Función para obtener o crear instancia del modal de error
    function getErrorModal() {
        if (!errorModalInstance) {
            const modalElement = document.getElementById('customErrorModal');
            errorModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        }
        return errorModalInstance;
    }
    
    // Función para mostrar alerta personalizada
    function showAlert(message, title = 'Información', type = 'info') {
        const modal = getAlertModal();
        const iconElement = document.getElementById('customAlertIcon');
        const titleElement = document.getElementById('customAlertTitleText');
        const messageElement = document.getElementById('customAlertMessage');
        
        // Configurar icono y color según el tipo
        const types = {
            'info': { icon: 'fa-info-circle', color: 'text-info' },
            'warning': { icon: 'fa-exclamation-triangle', color: 'text-warning' },
            'success': { icon: 'fa-check-circle', color: 'text-success' },
            'error': { icon: 'fa-times-circle', color: 'text-danger' }
        };
        
        const config = types[type] || types['info'];
        iconElement.className = `fas ${config.icon} me-2 ${config.color}`;
        titleElement.textContent = title;
        messageElement.textContent = message;
        
        modal.show();
    }
    
    // Función para mostrar confirmación personalizada
    function showConfirm(message, onConfirm, title = '¿Estás seguro?') {
        return new Promise((resolve) => {
            const modal = getConfirmModal();
            const titleElement = document.getElementById('customConfirmTitle');
            const messageElement = document.getElementById('customConfirmMessage');
            const confirmBtn = document.getElementById('customConfirmBtn');
            
            titleElement.textContent = title;
            messageElement.textContent = message;
            
            // Limpiar listeners anteriores
            const newConfirmBtn = confirmBtn.cloneNode(true);
            confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
            
            // Agregar nuevo listener
            document.getElementById('customConfirmBtn').addEventListener('click', function() {
                modal.hide();
                if (typeof onConfirm === 'function') {
                    onConfirm();
                }
                resolve(true);
            });
            
            // Resolver false si se cancela
            document.getElementById('customConfirmModal').addEventListener('hidden.bs.modal', function onHide() {
                resolve(false);
                this.removeEventListener('hidden.bs.modal', onHide);
            }, { once: true });
            
            modal.show();
        });
    }
    
    // Función para mostrar éxito
    function showSuccess(message) {
        const modal = getSuccessModal();
        document.getElementById('customSuccessMessage').textContent = message;
        modal.show();
    }
    
    // Función para mostrar error
    function showError(message) {
        const modal = getErrorModal();
        document.getElementById('customErrorMessage').textContent = message;
        modal.show();
    }
    
    // Reemplazar alert y confirm nativos (opcional)
    // window.alert = showAlert;
    // window.confirm = (msg) => showConfirm(msg, () => {});
</script>

