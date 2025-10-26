package com.wbhrs.webbasedhotelreservationsystemfortourists.dao;

import com.wbhrs.webbasedhotelreservationsystemfortourists.model.Review;
import com.wbhrs.webbasedhotelreservationsystemfortourists.util.DBconnect;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

	public List<Review> findAll() throws SQLException {
		final String sql = "SELECT ReviewID, TouristID, Title, Content, Rating, CreatedAt, UpdatedAt FROM Review ORDER BY CreatedAt DESC";
		try (Connection con = DBconnect.get(); PreparedStatement ps = con.prepareStatement(sql)) {
			try (ResultSet rs = ps.executeQuery()) {
				List<Review> list = new ArrayList<>();
				while (rs.next()) list.add(map(rs));
				return list;
			}
		}
	}

	public Review findById(long id) throws SQLException {
		final String sql = "SELECT ReviewID, TouristID, Title, Content, Rating, CreatedAt, UpdatedAt FROM Review WHERE ReviewID=?";
		try (Connection con = DBconnect.get(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, id);
			try (ResultSet rs = ps.executeQuery()) { return rs.next() ? map(rs) : null; }
		}
	}

	public long create(long touristId, String title, String content, int rating) throws SQLException {
		final String sql = "INSERT INTO Review (TouristID, Title, Content, Rating) VALUES (?,?,?,?)";
		try (Connection con = DBconnect.get(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
			ps.setLong(1, touristId);
			ps.setString(2, title);
			ps.setString(3, content);
			ps.setInt(4, rating);
			ps.executeUpdate();
			try (ResultSet keys = ps.getGeneratedKeys()) { return keys.next() ? keys.getLong(1) : -1L; }
		}
	}

	public boolean update(long reviewId, long touristId, String title, String content, int rating) throws SQLException {
		final String sql = "UPDATE Review SET Title=?, Content=?, Rating=?, UpdatedAt=CURRENT_TIMESTAMP WHERE ReviewID=? AND TouristID=?";
		try (Connection con = DBconnect.get(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, title);
			ps.setString(2, content);
			ps.setInt(3, rating);
			ps.setLong(4, reviewId);
			ps.setLong(5, touristId);
			return ps.executeUpdate() > 0;
		}
	}

	public boolean delete(long reviewId, long touristId) throws SQLException {
		final String sql = "DELETE FROM Review WHERE ReviewID=? AND TouristID=?";
		try (Connection con = DBconnect.get(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, reviewId);
			ps.setLong(2, touristId);
			return ps.executeUpdate() > 0;
		}
	}

	private Review map(ResultSet rs) throws SQLException {
		Review r = new Review();
		r.setReviewId(rs.getLong("ReviewID"));
		r.setTouristId(rs.getLong("TouristID"));
		r.setTitle(rs.getString("Title"));
		r.setContent(rs.getString("Content"));
		r.setRating(rs.getInt("Rating"));
		r.setCreatedAt(rs.getTimestamp("CreatedAt"));
		r.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
		return r;
	}
}


