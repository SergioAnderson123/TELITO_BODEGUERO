package com.example.telito.administrador.beans;

import java.sql.Date;

// Bean para representar un vehículo
public class Vehiculo {
    private int idVehiculo;
    private String placa;
    private String marca;
    private String modelo;
    private int capacidadKg;
    private Integer año;
    private String tipoCombustible;
    private String numeroSerieVin;
    private Date fechaUltimaRevision;
    private Date fechaVencimientoSoat;

    public Vehiculo() {
    }

    public Vehiculo(int idVehiculo, String placa, String marca, String modelo, int capacidadKg) {
        this.idVehiculo = idVehiculo;
        this.placa = placa;
        this.marca = marca;
        this.modelo = modelo;
        this.capacidadKg = capacidadKg;
    }

    public int getIdVehiculo() {
        return idVehiculo;
    }

    public void setIdVehiculo(int idVehiculo) {
        this.idVehiculo = idVehiculo;
    }

    public String getPlaca() {
        return placa;
    }

    public void setPlaca(String placa) {
        this.placa = placa;
    }

    public String getMarca() {
        return marca;
    }

    public void setMarca(String marca) {
        this.marca = marca;
    }

    public String getModelo() {
        return modelo;
    }

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }

    public int getCapacidadKg() {
        return capacidadKg;
    }

    public void setCapacidadKg(int capacidadKg) {
        this.capacidadKg = capacidadKg;
    }

    public Integer getAño() {
        return año;
    }

    public void setAño(Integer año) {
        this.año = año;
    }

    public String getTipoCombustible() {
        return tipoCombustible;
    }

    public void setTipoCombustible(String tipoCombustible) {
        this.tipoCombustible = tipoCombustible;
    }

    public String getNumeroSerieVin() {
        return numeroSerieVin;
    }

    public void setNumeroSerieVin(String numeroSerieVin) {
        this.numeroSerieVin = numeroSerieVin;
    }

    public Date getFechaUltimaRevision() {
        return fechaUltimaRevision;
    }

    public void setFechaUltimaRevision(Date fechaUltimaRevision) {
        this.fechaUltimaRevision = fechaUltimaRevision;
    }

    public Date getFechaVencimientoSoat() {
        return fechaVencimientoSoat;
    }

    public void setFechaVencimientoSoat(Date fechaVencimientoSoat) {
        this.fechaVencimientoSoat = fechaVencimientoSoat;
    }
}

