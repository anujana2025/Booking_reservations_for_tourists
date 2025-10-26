package com.wbhrs.webbasedhotelreservationsystemfortourists.model;

import java.sql.Timestamp;

public class Review {

	private Long reviewId;
	private Long touristId;
	private String title;
	private String content;
	private int rating; // 1..5
	private Timestamp createdAt;
	private Timestamp updatedAt;

	public Long getReviewId() { return reviewId; }
	public void setReviewId(Long reviewId) { this.reviewId = reviewId; }

	public Long getTouristId() { return touristId; }
	public void setTouristId(Long touristId) { this.touristId = touristId; }

	public String getTitle() { return title; }
	public void setTitle(String title) { this.title = title; }

	public String getContent() { return content; }
	public void setContent(String content) { this.content = content; }

	public int getRating() { return rating; }
	public void setRating(int rating) { this.rating = rating; }

	public Timestamp getCreatedAt() { return createdAt; }
	public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

	public Timestamp getUpdatedAt() { return updatedAt; }
	public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}


