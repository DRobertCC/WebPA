package com.codecool.web.model;

import java.util.Objects;

public final class User {

    private int id;
    private String surname;
    private String firstname;
    private String email;
    private String password;
    private String phone;
    private String country;
    private String postal_code_and_city;
    private String rest_of_address;
    private int number_of_recent_visits;
    private int sum_of_all_recent_booked_nights;
    private Role role;

    public User(int id, String surname, String firstname, String email, String password, String phone, String country, String postal_code_and_city, String rest_of_address, int number_of_recent_visits, int sum_of_all_recent_booked_nights, Role role) {
        this.id = id;
        this.surname = surname;
        this.firstname = firstname;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.country = country;
        this.postal_code_and_city = postal_code_and_city;
        this.rest_of_address = rest_of_address;
        this.number_of_recent_visits = number_of_recent_visits;
        this.sum_of_all_recent_booked_nights = sum_of_all_recent_booked_nights;
        this.role = role;
    }

    public int getId() {
        return id;
    }

    public String getSurname() {
        return surname;
    }

    public String getFirstname() {
        return firstname;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getPhone() {
        return phone;
    }

    public String getCountry() {
        return country;
    }

    public String getPostal_code_and_city() {
        return postal_code_and_city;
    }

    public String getRest_of_address() {
        return rest_of_address;
    }

    public int getNumber_of_recent_visits() {
        return number_of_recent_visits;
    }

    public int getSum_of_all_recent_booked_nights() {
        return sum_of_all_recent_booked_nights;
    }

    public Role getRole() {
        return role;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return surname.equals(user.surname) &&
            firstname.equals(user.firstname) &&
            email.equals(user.email);
    }

    @Override
    public int hashCode() {
        return Objects.hash(surname, firstname, email);
    }
}
