package com.wbhrs.webbasedhotelreservationsystemfortourists.dao;

import com.wbhrs.webbasedhotelreservationsystemfortourists.model.FAQ;
import com.wbhrs.webbasedhotelreservationsystemfortourists.util.DBconnect;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FAQDAO {

	public List<FAQ> findAll() throws SQLException {
		final String sql = "SELECT FaqID, Question, Answer, CreatedAt, UpdatedAt FROM FAQ ORDER BY CreatedAt DESC";
		try (Connection con = DBconnect.get(); PreparedStatement ps = con.prepareStatement(sql)) {
			try (ResultSet rs = ps.executeQuery()) {
				List<FAQ> list = new ArrayList<>();
				while (rs.next()) list.add(map(rs));
				return list;
			}
		}
	}

	public long create(String question, String answer) throws SQLException {
		final String sql = "INSERT INTO FAQ (Question, Answer) VALUES (?,?)";
		try (Connection con = DBconnect.get(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
			ps.setString(1, question);
			ps.setString(2, answer);
			ps.executeUpdate();
			try (ResultSet keys = ps.getGeneratedKeys()) { return keys.next() ? keys.getLong(1) : -1L; }
		}
	}

	public boolean update(long faqId, String question, String answer) throws SQLException {
		final String sql = "UPDATE FAQ SET Question=?, Answer=?, UpdatedAt=CURRENT_TIMESTAMP WHERE FaqID=?";
		try (Connection con = DBconnect.get(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, question);
			ps.setString(2, answer);
			ps.setLong(3, faqId);
			return ps.executeUpdate() > 0;
		}
	}

	public boolean delete(long faqId) throws SQLException {
		final String sql = "DELETE FROM FAQ WHERE FaqID=?";
		try (Connection con = DBconnect.get(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, faqId);
			return ps.executeUpdate() > 0;
		}
	}

	private FAQ map(ResultSet rs) throws SQLException {
		FAQ f = new FAQ();
		f.setFaqId(rs.getLong("FaqID"));
		f.setQuestion(rs.getString("Question"));
		f.setAnswer(rs.getString("Answer"));
		f.setCreatedAt(rs.getTimestamp("CreatedAt"));
		f.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
		return f;
	}
}


