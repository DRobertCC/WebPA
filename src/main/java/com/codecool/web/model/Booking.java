package com.codecool.web.model;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.Objects;

public final class Booking {

    private int user_id;
    private LocalDate arrival_date; // LocalDate date = LocalDate.new(1979, 1, 10);
    private int number_of_nights;
    private int number_of_apartmans_needed;
    private int total_number_of_guests;
    private int number_of_children;
    private Integer[] agelist_of_children;
    private int arrival_hour;
    private int leaving_hour;

    public int getUser_id() {
        return user_id;
    }

    public LocalDate getArrival_date() {
        return arrival_date;
    }

    public int getNumber_of_nights() {
        return number_of_nights;
    }

    public int getNumber_of_apartmans_needed() {
        return number_of_apartmans_needed;
    }

    public int getTotal_number_of_guests() {
        return total_number_of_guests;
    }

    public int getNumber_of_children() {
        return number_of_children;
    }

    public Integer[] getAgelist_of_children() {
        return agelist_of_children;
    }

    public int getArrival_hour() {
        return arrival_hour;
    }

    public int getLeaving_hour() {
        return leaving_hour;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Booking booking = (Booking) o;
        return user_id == booking.user_id &&
            number_of_nights == booking.number_of_nights &&
            number_of_apartmans_needed == booking.number_of_apartmans_needed &&
            total_number_of_guests == booking.total_number_of_guests &&
            number_of_children == booking.number_of_children &&
            arrival_hour == booking.arrival_hour &&
            leaving_hour == booking.leaving_hour &&
            arrival_date.equals(booking.arrival_date) &&
            Arrays.equals(agelist_of_children, booking.agelist_of_children);
    }

    @Override
    public int hashCode() {
        int result = Objects.hash(user_id, arrival_date, number_of_nights, number_of_apartmans_needed, total_number_of_guests, number_of_children, arrival_hour, leaving_hour);
        result = 31 * result + Arrays.hashCode(agelist_of_children);
        return result;
    }
}
