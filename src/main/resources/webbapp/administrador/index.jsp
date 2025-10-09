<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bienvenido a Telito Bodeguero</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            /* Background image with a dark overlay for readability */
            background-image: linear-gradient(rgba(0, 0, 0, 0.6), rgba(0, 0, 0, 0.6)), url('https://images.unsplash.com/photo-1565895405137-3ca0cc50911c?q=80&w=2070&auto=format&fit=crop');
            background-size: cover;
            background-position: center;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .main-container {
            background: rgba(255, 255, 255, 0.98);
            padding: 40px 50px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            text-align: center;
            max-width: 500px;
            width: 100%;
        }
        .main-container h1 {
            color: #2c3e50;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .main-container p {
            color: #34495e;
            margin-bottom: 30px;
        }
        .role-selection .btn {
            width: 100%;
            margin-bottom: 15px;
            padding: 12px;
            font-size: 16px;
            font-weight: 600;
            border-radius: 8px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .role-selection .btn:hover:not(.disabled) {
            transform: translateY(-3px);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }
        .btn-primary {
            background-color: #007bff;
            border-color: #007bff;
        }
        .btn-primary:hover {
            background-color: #0069d9;
            border-color: #0062cc;
        }
        .btn-secondary.disabled {
            background-color: #e9ecef;
            border-color: #e9ecef;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="main-container">
        <h1>Bienvenido a Telito Bodeguero</h1>
        <p>Por favor, seleccione su rol para continuar.</p>
        <div class="role-selection">
            <a href="<%= request.getContextPath() %>/inicio" class="btn btn-primary">Administrador</a>
            <a href="#" class="btn btn-secondary disabled" aria-disabled="true">Productor</a>
            <a href="#" class="btn btn-secondary disabled" aria-disabled="true">Logistica</a>
            <a href="#" class="btn btn-secondary disabled" aria-disabled="true">Almacen</a>
        </div>
    </div>
</body>
</html>
