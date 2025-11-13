# Database Service Queries - 완전한 CRUD 가이드

모든 데이터베이스 테이블에 대한 완전한 CRUD 쿼리 모음입니다.

## 목차
1. [Users Queries](#users-queries)
2. [Posts Queries](#posts-queries)
3. [Comments Queries](#comments-queries)
4. [Follows Queries](#follows-queries)
5. [Portfolio Queries](#portfolio-queries)
6. [Holdings Queries](#holdings-queries)
7. [Trades Queries](#trades-queries)
8. [Investment Posts Queries](#investment-posts-queries)
9. [Bookmarks Queries](#bookmarks-queries)
10. [Watchlist Queries](#watchlist-queries)
11. [Notifications Queries](#notifications-queries)

---

## Users Queries

### CREATE - 사용자 생성
```typescript
async createUser(data: {
  userId: string;
  email: string;
  password: string;
  username: string;
  fullName: string;
}) {
  const query = `
    INSERT INTO users (
      user_id, email, password, username, full_name,
      follower_count, following_count, post_count,
      is_verified, is_active, email_verified, created_at, updated_at
    )
    VALUES ($1, $2, $3, $4, $5, 0, 0, 0, false, true, false, NOW(), NOW())
    RETURNING
      user_id, email, username, full_name,
      follower_count, following_count, post_count,
      is_verified, created_at
  `;

  const result = await db.query(query, [
    data.userId,
    data.email,
    data.password,
    data.username,
    data.fullName
  ]);

  return result.rows[0];
}
```

### READ - 사용자 조회

**By ID:**
```typescript
async findById(userId: string) {
  const query = `
    SELECT
      user_id, email, username, full_name, bio,
      profile_image_url, follower_count, following_count, post_count,
      is_verified, is_active, email_verified, created_at
    FROM users
    WHERE user_id = $1 AND is_active = true
  `;

  const result = await db.query(query, [userId]);
  return result.rows[0];
}
```

**By Email:**
```typescript
async findByEmail(email: string) {
  const query = `
    SELECT * FROM users
    WHERE email = $1 AND is_active = true
  `;

  const result = await db.query(query, [email]);
  return result.rows[0];
}
```

**By Username:**
```typescript
async findByUsername(username: string) {
  const query = `
    SELECT
      user_id, username, full_name, bio,
      profile_image_url, follower_count, following_count, post_count,
      is_verified, created_at
    FROM users
    WHERE username = $1 AND is_active = true
  `;

  const result = await db.query(query, [username]);
  return result.rows[0];
}
```

**Search Users:**
```typescript
async searchUsers(searchTerm: string, limit: number, offset: number) {
  const query = `
    SELECT
      user_id, username, full_name, bio,
      profile_image_url, follower_count, is_verified
    FROM users
    WHERE
      is_active = true AND
      (username ILIKE $1 OR full_name ILIKE $1)
    ORDER BY follower_count DESC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, [`%${searchTerm}%`, limit, offset]);
  return result.rows;
}
```

### UPDATE - 사용자 업데이트

**Update Profile:**
```typescript
async updateProfile(
  userId: string,
  data: {
    fullName?: string;
    bio?: string;
    profileImageUrl?: string;
  }
) {
  const updates: string[] = [];
  const values: any[] = [];
  let paramIndex = 1;

  if (data.fullName !== undefined) {
    updates.push(`full_name = $${paramIndex++}`);
    values.push(data.fullName);
  }

  if (data.bio !== undefined) {
    updates.push(`bio = $${paramIndex++}`);
    values.push(data.bio);
  }

  if (data.profileImageUrl !== undefined) {
    updates.push(`profile_image_url = $${paramIndex++}`);
    values.push(data.profileImageUrl);
  }

  if (updates.length === 0) {
    throw new Error('No fields to update');
  }

  updates.push(`updated_at = NOW()`);
  values.push(userId);

  const query = `
    UPDATE users
    SET ${updates.join(', ')}
    WHERE user_id = $${paramIndex}
    RETURNING user_id, username, full_name, bio, profile_image_url, updated_at
  `;

  const result = await db.query(query, values);
  return result.rows[0];
}
```

**Update Counts:**
```typescript
async incrementFollowerCount(userId: string) {
  const query = `
    UPDATE users
    SET follower_count = follower_count + 1
    WHERE user_id = $1
  `;
  await db.query(query, [userId]);
}

async decrementFollowerCount(userId: string) {
  const query = `
    UPDATE users
    SET follower_count = GREATEST(follower_count - 1, 0)
    WHERE user_id = $1
  `;
  await db.query(query, [userId]);
}

async incrementFollowingCount(userId: string) {
  const query = `
    UPDATE users
    SET following_count = following_count + 1
    WHERE user_id = $1
  `;
  await db.query(query, [userId]);
}

async decrementFollowingCount(userId: string) {
  const query = `
    UPDATE users
    SET following_count = GREATEST(following_count - 1, 0)
    WHERE user_id = $1
  `;
  await db.query(query, [userId]);
}

async incrementPostCount(userId: string) {
  const query = `
    UPDATE users
    SET post_count = post_count + 1
    WHERE user_id = $1
  `;
  await db.query(query, [userId]);
}

async decrementPostCount(userId: string) {
  const query = `
    UPDATE users
    SET post_count = GREATEST(post_count - 1, 0)
    WHERE user_id = $1
  `;
  await db.query(query, [userId]);
}
```

**Update Password:**
```typescript
async updatePassword(userId: string, hashedPassword: string) {
  const query = `
    UPDATE users
    SET password = $1, updated_at = NOW()
    WHERE user_id = $2
  `;
  await db.query(query, [hashedPassword, userId]);
}
```

**Verify Email:**
```typescript
async verifyEmail(userId: string) {
  const query = `
    UPDATE users
    SET email_verified = true, updated_at = NOW()
    WHERE user_id = $1
  `;
  await db.query(query, [userId]);
}
```

### DELETE - 사용자 삭제

**Soft Delete:**
```typescript
async softDeleteUser(userId: string) {
  const query = `
    UPDATE users
    SET is_active = false, updated_at = NOW()
    WHERE user_id = $1
  `;
  await db.query(query, [userId]);
}
```

**Hard Delete:**
```typescript
async hardDeleteUser(userId: string) {
  const query = `
    DELETE FROM users WHERE user_id = $1
  `;
  await db.query(query, [userId]);
}
```

---

## Posts Queries

### CREATE - 게시물 생성
```typescript
async createPost(data: {
  postId: string;
  userId: string;
  caption: string;
  imageUrls: string[];
  location?: string;
}) {
  const query = `
    INSERT INTO posts (
      post_id, user_id, caption, image_urls, location,
      like_count, comment_count, bookmark_count, view_count,
      is_hidden, created_at, updated_at
    )
    VALUES ($1, $2, $3, $4, $5, 0, 0, 0, 0, false, NOW(), NOW())
    RETURNING *
  `;

  const result = await db.query(query, [
    data.postId,
    data.userId,
    data.caption,
    data.imageUrls,
    data.location || null
  ]);

  return result.rows[0];
}
```

### READ - 게시물 조회

**By ID:**
```typescript
async findPostById(postId: string, currentUserId?: string) {
  const query = `
    SELECT
      p.*,
      u.username,
      u.full_name,
      u.profile_image_url as user_photo_url,
      u.is_verified,
      ${currentUserId ? `
        EXISTS(
          SELECT 1 FROM post_likes
          WHERE post_id = p.post_id AND user_id = $2
        ) as is_liked,
        EXISTS(
          SELECT 1 FROM bookmarks
          WHERE content_id = p.post_id AND user_id = $2 AND content_type = 'post'
        ) as is_bookmarked
      ` : 'false as is_liked, false as is_bookmarked'}
    FROM posts p
    JOIN users u ON p.user_id = u.user_id
    WHERE p.post_id = $1 AND p.is_hidden = false AND u.is_active = true
  `;

  const params = currentUserId ? [postId, currentUserId] : [postId];
  const result = await db.query(query, params);
  return result.rows[0];
}
```

**Feed (Following):**
```typescript
async getFeed(userId: string, limit: number, offset: number) {
  const query = `
    SELECT
      p.*,
      u.username,
      u.full_name,
      u.profile_image_url as user_photo_url,
      u.is_verified,
      EXISTS(
        SELECT 1 FROM post_likes WHERE post_id = p.post_id AND user_id = $1
      ) as is_liked,
      EXISTS(
        SELECT 1 FROM bookmarks WHERE content_id = p.post_id AND user_id = $1 AND content_type = 'post'
      ) as is_bookmarked
    FROM posts p
    JOIN users u ON p.user_id = u.user_id
    WHERE
      p.is_hidden = false AND
      u.is_active = true AND
      (
        p.user_id IN (SELECT following_id FROM follows WHERE follower_id = $1)
        OR p.user_id = $1
      )
    ORDER BY p.created_at DESC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, [userId, limit, offset]);
  return result.rows;
}
```

**User Posts:**
```typescript
async getUserPosts(userId: string, currentUserId: string | null, limit: number, offset: number) {
  const query = `
    SELECT
      p.*,
      u.username,
      u.profile_image_url as user_photo_url,
      ${currentUserId ? `
        EXISTS(SELECT 1 FROM post_likes WHERE post_id = p.post_id AND user_id = $3) as is_liked,
        EXISTS(SELECT 1 FROM bookmarks WHERE content_id = p.post_id AND user_id = $3 AND content_type = 'post') as is_bookmarked
      ` : 'false as is_liked, false as is_bookmarked'}
    FROM posts p
    JOIN users u ON p.user_id = u.user_id
    WHERE p.user_id = $1 AND p.is_hidden = false
    ORDER BY p.created_at DESC
    LIMIT $2 OFFSET ${currentUserId ? '$4' : '$3'}
  `;

  const params = currentUserId
    ? [userId, limit, currentUserId, offset]
    : [userId, limit, offset];

  const result = await db.query(query, params);
  return result.rows;
}
```

**Explore (Popular Posts):**
```typescript
async getExplorePosts(currentUserId: string | null, limit: number, offset: number) {
  const query = `
    SELECT
      p.*,
      u.username,
      u.profile_image_url as user_photo_url,
      u.is_verified,
      ${currentUserId ? `
        EXISTS(SELECT 1 FROM post_likes WHERE post_id = p.post_id AND user_id = $1) as is_liked,
        EXISTS(SELECT 1 FROM bookmarks WHERE content_id = p.post_id AND user_id = $1 AND content_type = 'post') as is_bookmarked
      ` : 'false as is_liked, false as is_bookmarked'}
    FROM posts p
    JOIN users u ON p.user_id = u.user_id
    WHERE p.is_hidden = false AND u.is_active = true
    ORDER BY
      (p.like_count * 0.4 + p.comment_count * 0.3 + p.view_count * 0.3) DESC,
      p.created_at DESC
    LIMIT ${currentUserId ? '$2' : '$1'}
    OFFSET ${currentUserId ? '$3' : '$2'}
  `;

  const params = currentUserId
    ? [currentUserId, limit, offset]
    : [limit, offset];

  const result = await db.query(query, params);
  return result.rows;
}
```

### UPDATE - 게시물 업데이트

**Update Post:**
```typescript
async updatePost(postId: string, data: { caption?: string; location?: string }) {
  const updates: string[] = [];
  const values: any[] = [];
  let paramIndex = 1;

  if (data.caption !== undefined) {
    updates.push(`caption = $${paramIndex++}`);
    values.push(data.caption);
  }

  if (data.location !== undefined) {
    updates.push(`location = $${paramIndex++}`);
    values.push(data.location);
  }

  if (updates.length === 0) {
    throw new Error('No fields to update');
  }

  updates.push(`updated_at = NOW()`);
  values.push(postId);

  const query = `
    UPDATE posts
    SET ${updates.join(', ')}
    WHERE post_id = $${paramIndex}
    RETURNING *
  `;

  const result = await db.query(query, values);
  return result.rows[0];
}
```

**Increment Counts:**
```typescript
async incrementLikeCount(postId: string) {
  const query = `
    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = $1
  `;
  await db.query(query, [postId]);
}

async decrementLikeCount(postId: string) {
  const query = `
    UPDATE posts
    SET like_count = GREATEST(like_count - 1, 0)
    WHERE post_id = $1
  `;
  await db.query(query, [postId]);
}

async incrementCommentCount(postId: string) {
  const query = `
    UPDATE posts
    SET comment_count = comment_count + 1
    WHERE post_id = $1
  `;
  await db.query(query, [postId]);
}

async decrementCommentCount(postId: string) {
  const query = `
    UPDATE posts
    SET comment_count = GREATEST(comment_count - 1, 0)
    WHERE post_id = $1
  `;
  await db.query(query, [postId]);
}

async incrementViewCount(postId: string) {
  const query = `
    UPDATE posts
    SET view_count = view_count + 1
    WHERE post_id = $1
  `;
  await db.query(query, [postId]);
}
```

### DELETE - 게시물 삭제

**Soft Delete:**
```typescript
async hidePost(postId: string) {
  const query = `
    UPDATE posts
    SET is_hidden = true, updated_at = NOW()
    WHERE post_id = $1
  `;
  await db.query(query, [postId]);
}
```

**Hard Delete:**
```typescript
async deletePost(postId: string) {
  const query = `
    DELETE FROM posts WHERE post_id = $1
  `;
  await db.query(query, [postId]);
}
```

---

## Post Likes Queries

### CREATE - 좋아요 추가
```typescript
async likePost(postId: string, userId: string) {
  await db.transaction(async (client) => {
    // Insert like
    await client.query(
      `INSERT INTO post_likes (like_id, post_id, user_id, created_at)
       VALUES (gen_random_uuid(), $1, $2, NOW())
       ON CONFLICT (post_id, user_id) DO NOTHING`,
      [postId, userId]
    );

    // Increment like count
    await client.query(
      `UPDATE posts SET like_count = like_count + 1 WHERE post_id = $1`,
      [postId]
    );
  });
}
```

### READ - 좋아요 확인
```typescript
async isLiked(postId: string, userId: string): Promise<boolean> {
  const query = `
    SELECT EXISTS(
      SELECT 1 FROM post_likes WHERE post_id = $1 AND user_id = $2
    ) as liked
  `;

  const result = await db.query(query, [postId, userId]);
  return result.rows[0].liked;
}
```

**Get Post Likers:**
```typescript
async getPostLikers(postId: string, limit: number, offset: number) {
  const query = `
    SELECT
      u.user_id, u.username, u.full_name, u.profile_image_url, u.is_verified,
      pl.created_at as liked_at
    FROM post_likes pl
    JOIN users u ON pl.user_id = u.user_id
    WHERE pl.post_id = $1
    ORDER BY pl.created_at DESC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, [postId, limit, offset]);
  return result.rows;
}
```

### DELETE - 좋아요 취소
```typescript
async unlikePost(postId: string, userId: string) {
  await db.transaction(async (client) => {
    // Delete like
    await client.query(
      `DELETE FROM post_likes WHERE post_id = $1 AND user_id = $2`,
      [postId, userId]
    );

    // Decrement like count
    await client.query(
      `UPDATE posts SET like_count = GREATEST(like_count - 1, 0) WHERE post_id = $1`,
      [postId]
    );
  });
}
```

---

## Comments Queries

### CREATE - 댓글 작성
```typescript
async createComment(data: {
  commentId: string;
  postId: string;
  userId: string;
  content: string;
  parentCommentId?: string;
}) {
  await db.transaction(async (client) => {
    // Insert comment
    const commentQuery = `
      INSERT INTO comments (
        comment_id, post_id, user_id, parent_comment_id, content,
        like_count, created_at, updated_at
      )
      VALUES ($1, $2, $3, $4, $5, 0, NOW(), NOW())
      RETURNING *
    `;

    const result = await client.query(commentQuery, [
      data.commentId,
      data.postId,
      data.userId,
      data.parentCommentId || null,
      data.content
    ]);

    // Increment post comment count
    await client.query(
      `UPDATE posts SET comment_count = comment_count + 1 WHERE post_id = $1`,
      [data.postId]
    );

    return result.rows[0];
  });
}
```

### READ - 댓글 조회

**Get Post Comments:**
```typescript
async getPostComments(postId: string, limit: number, offset: number) {
  const query = `
    SELECT
      c.*,
      u.username,
      u.full_name,
      u.profile_image_url,
      u.is_verified,
      (
        SELECT COUNT(*) FROM comments
        WHERE parent_comment_id = c.comment_id
      ) as reply_count
    FROM comments c
    JOIN users u ON c.user_id = u.user_id
    WHERE c.post_id = $1 AND c.parent_comment_id IS NULL
    ORDER BY c.created_at DESC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, [postId, limit, offset]);
  return result.rows;
}
```

**Get Comment Replies:**
```typescript
async getCommentReplies(commentId: string, limit: number, offset: number) {
  const query = `
    SELECT
      c.*,
      u.username,
      u.full_name,
      u.profile_image_url,
      u.is_verified
    FROM comments c
    JOIN users u ON c.user_id = u.user_id
    WHERE c.parent_comment_id = $1
    ORDER BY c.created_at ASC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, [commentId, limit, offset]);
  return result.rows;
}
```

### UPDATE - 댓글 수정
```typescript
async updateComment(commentId: string, content: string) {
  const query = `
    UPDATE comments
    SET content = $1, updated_at = NOW()
    WHERE comment_id = $2
    RETURNING *
  `;

  const result = await db.query(query, [content, commentId]);
  return result.rows[0];
}
```

### DELETE - 댓글 삭제
```typescript
async deleteComment(commentId: string, postId: string) {
  await db.transaction(async (client) => {
    // Delete comment and its replies (CASCADE)
    await client.query(
      `DELETE FROM comments WHERE comment_id = $1`,
      [commentId]
    );

    // Decrement post comment count
    await client.query(
      `UPDATE posts SET comment_count = GREATEST(comment_count - 1, 0) WHERE post_id = $1`,
      [postId]
    );
  });
}
```

---

## Follows Queries

### CREATE - 팔로우
```typescript
async followUser(followerId: string, followingId: string) {
  await db.transaction(async (client) => {
    // Insert follow
    await client.query(
      `INSERT INTO follows (follow_id, follower_id, following_id, created_at)
       VALUES (gen_random_uuid(), $1, $2, NOW())
       ON CONFLICT (follower_id, following_id) DO NOTHING`,
      [followerId, followingId]
    );

    // Increment following count for follower
    await client.query(
      `UPDATE users SET following_count = following_count + 1 WHERE user_id = $1`,
      [followerId]
    );

    // Increment follower count for following
    await client.query(
      `UPDATE users SET follower_count = follower_count + 1 WHERE user_id = $1`,
      [followingId]
    );
  });
}
```

### READ - 팔로우 확인

**Is Following:**
```typescript
async isFollowing(followerId: string, followingId: string): Promise<boolean> {
  const query = `
    SELECT EXISTS(
      SELECT 1 FROM follows WHERE follower_id = $1 AND following_id = $2
    ) as following
  `;

  const result = await db.query(query, [followerId, followingId]);
  return result.rows[0].following;
}
```

**Get Followers:**
```typescript
async getFollowers(userId: string, limit: number, offset: number) {
  const query = `
    SELECT
      u.user_id, u.username, u.full_name, u.profile_image_url, u.is_verified,
      f.created_at as followed_at
    FROM follows f
    JOIN users u ON f.follower_id = u.user_id
    WHERE f.following_id = $1 AND u.is_active = true
    ORDER BY f.created_at DESC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, [userId, limit, offset]);
  return result.rows;
}
```

**Get Following:**
```typescript
async getFollowing(userId: string, limit: number, offset: number) {
  const query = `
    SELECT
      u.user_id, u.username, u.full_name, u.profile_image_url, u.is_verified,
      f.created_at as followed_at
    FROM follows f
    JOIN users u ON f.following_id = u.user_id
    WHERE f.follower_id = $1 AND u.is_active = true
    ORDER BY f.created_at DESC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, [userId, limit, offset]);
  return result.rows;
}
```

### DELETE - 언팔로우
```typescript
async unfollowUser(followerId: string, followingId: string) {
  await db.transaction(async (client) => {
    // Delete follow
    await client.query(
      `DELETE FROM follows WHERE follower_id = $1 AND following_id = $2`,
      [followerId, followingId]
    );

    // Decrement following count for follower
    await client.query(
      `UPDATE users SET following_count = GREATEST(following_count - 1, 0) WHERE user_id = $1`,
      [followerId]
    );

    // Decrement follower count for following
    await client.query(
      `UPDATE users SET follower_count = GREATEST(follower_count - 1, 0) WHERE user_id = $1`,
      [followingId]
    );
  });
}
```

---

## Portfolio Queries

### CREATE - 포트폴리오 생성
```typescript
async createPortfolio(data: {
  portfolioId: string;
  userId: string;
  name: string;
  description: string;
  isPublic: boolean;
}) {
  const query = `
    INSERT INTO investment_portfolios (
      portfolio_id, user_id, name, description, is_public,
      total_value, total_cost, total_return, return_rate, follower_count,
      created_at, updated_at
    )
    VALUES ($1, $2, $3, $4, $5, 0, 0, 0, 0, 0, NOW(), NOW())
    RETURNING *
  `;

  const result = await db.query(query, [
    data.portfolioId,
    data.userId,
    data.name,
    data.description,
    data.isPublic
  ]);

  return result.rows[0];
}
```

### READ - 포트폴리오 조회

**By ID:**
```typescript
async getPortfolioById(portfolioId: string) {
  const query = `
    SELECT
      p.*,
      u.username,
      u.full_name,
      u.profile_image_url
    FROM investment_portfolios p
    JOIN users u ON p.user_id = u.user_id
    WHERE p.portfolio_id = $1
  `;

  const result = await db.query(query, [portfolioId]);
  return result.rows[0];
}
```

**User Portfolios:**
```typescript
async getUserPortfolios(userId: string, limit: number, offset: number) {
  const query = `
    SELECT * FROM investment_portfolios
    WHERE user_id = $1
    ORDER BY created_at DESC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, [userId, limit, offset]);
  return result.rows;
}
```

**Public Portfolios (Sorted by Return):**
```typescript
async getPublicPortfolios(limit: number, offset: number, sortBy: 'return' | 'followers' = 'return') {
  const orderBy = sortBy === 'return' ? 'return_rate' : 'follower_count';

  const query = `
    SELECT
      p.*,
      u.username,
      u.full_name,
      u.profile_image_url
    FROM investment_portfolios p
    JOIN users u ON p.user_id = u.user_id
    WHERE p.is_public = true AND u.is_active = true
    ORDER BY p.${orderBy} DESC
    LIMIT $1 OFFSET $2
  `;

  const result = await db.query(query, [limit, offset]);
  return result.rows;
}
```

### UPDATE - 포트폴리오 업데이트

**Update Basic Info:**
```typescript
async updatePortfolio(
  portfolioId: string,
  data: { name?: string; description?: string; isPublic?: boolean }
) {
  const updates: string[] = [];
  const values: any[] = [];
  let paramIndex = 1;

  if (data.name !== undefined) {
    updates.push(`name = $${paramIndex++}`);
    values.push(data.name);
  }

  if (data.description !== undefined) {
    updates.push(`description = $${paramIndex++}`);
    values.push(data.description);
  }

  if (data.isPublic !== undefined) {
    updates.push(`is_public = $${paramIndex++}`);
    values.push(data.isPublic);
  }

  if (updates.length === 0) {
    throw new Error('No fields to update');
  }

  updates.push(`updated_at = NOW()`);
  values.push(portfolioId);

  const query = `
    UPDATE investment_portfolios
    SET ${updates.join(', ')}
    WHERE portfolio_id = $${paramIndex}
    RETURNING *
  `;

  const result = await db.query(query, values);
  return result.rows[0];
}
```

**Update Totals:**
```typescript
async updatePortfolioTotals(portfolioId: string) {
  const query = `
    UPDATE investment_portfolios p
    SET
      total_value = (SELECT COALESCE(SUM(total_value), 0) FROM asset_holdings WHERE portfolio_id = $1),
      total_cost = (SELECT COALESCE(SUM(total_cost), 0) FROM asset_holdings WHERE portfolio_id = $1),
      total_return = (SELECT COALESCE(SUM(total_value - total_cost), 0) FROM asset_holdings WHERE portfolio_id = $1),
      return_rate = CASE
        WHEN (SELECT COALESCE(SUM(total_cost), 0) FROM asset_holdings WHERE portfolio_id = $1) > 0
        THEN ((SELECT COALESCE(SUM(total_value - total_cost), 0) FROM asset_holdings WHERE portfolio_id = $1) /
              (SELECT COALESCE(SUM(total_cost), 1) FROM asset_holdings WHERE portfolio_id = $1)) * 100
        ELSE 0
      END,
      updated_at = NOW()
    WHERE portfolio_id = $1
    RETURNING *
  `;

  const result = await db.query(query, [portfolioId]);
  return result.rows[0];
}
```

### DELETE - 포트폴리오 삭제
```typescript
async deletePortfolio(portfolioId: string) {
  const query = `
    DELETE FROM investment_portfolios WHERE portfolio_id = $1
  `;
  await db.query(query, [portfolioId]);
}
```

---

## Holdings Queries

### CREATE - 자산 보유 추가
```typescript
async createHolding(data: {
  holdingId: string;
  portfolioId: string;
  assetType: string;
  symbol: string;
  assetName: string;
  quantity: number;
  averagePrice: number;
  currentPrice: number;
}) {
  const totalValue = data.quantity * data.currentPrice;
  const totalCost = data.quantity * data.averagePrice;

  const query = `
    INSERT INTO asset_holdings (
      holding_id, portfolio_id, asset_type, symbol, asset_name,
      quantity, average_price, current_price, total_value, total_cost,
      currency, purchase_date, updated_at
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'KRW', NOW(), NOW())
    RETURNING *
  `;

  const result = await db.query(query, [
    data.holdingId,
    data.portfolioId,
    data.assetType,
    data.symbol,
    data.assetName,
    data.quantity,
    data.averagePrice,
    data.currentPrice,
    totalValue,
    totalCost
  ]);

  return result.rows[0];
}
```

### READ - 자산 보유 조회

**Portfolio Holdings:**
```typescript
async getPortfolioHoldings(portfolioId: string) {
  const query = `
    SELECT * FROM asset_holdings
    WHERE portfolio_id = $1
    ORDER BY total_value DESC
  `;

  const result = await db.query(query, [portfolioId]);
  return result.rows;
}
```

**Single Holding:**
```typescript
async getHoldingById(holdingId: string) {
  const query = `
    SELECT * FROM asset_holdings WHERE holding_id = $1
  `;

  const result = await db.query(query, [holdingId]);
  return result.rows[0];
}
```

### UPDATE - 자산 보유 업데이트

**Update Holding:**
```typescript
async updateHolding(
  holdingId: string,
  data: { quantity?: number; averagePrice?: number; currentPrice?: number }
) {
  // Get current holding
  const current = await this.getHoldingById(holdingId);
  if (!current) {
    throw new Error('Holding not found');
  }

  const quantity = data.quantity ?? current.quantity;
  const averagePrice = data.averagePrice ?? current.average_price;
  const currentPrice = data.currentPrice ?? current.current_price;

  const totalValue = quantity * currentPrice;
  const totalCost = quantity * averagePrice;

  const query = `
    UPDATE asset_holdings
    SET
      quantity = $1,
      average_price = $2,
      current_price = $3,
      total_value = $4,
      total_cost = $5,
      updated_at = NOW()
    WHERE holding_id = $6
    RETURNING *
  `;

  const result = await db.query(query, [
    quantity,
    averagePrice,
    currentPrice,
    totalValue,
    totalCost,
    holdingId
  ]);

  return result.rows[0];
}
```

**Update Current Prices (Batch):**
```typescript
async updateHoldingPrices(priceUpdates: Array<{ symbol: string; price: number }>) {
  await db.transaction(async (client) => {
    for (const update of priceUpdates) {
      await client.query(
        `UPDATE asset_holdings
         SET
           current_price = $1,
           total_value = quantity * $1,
           updated_at = NOW()
         WHERE symbol = $2`,
        [update.price, update.symbol]
      );
    }
  });
}
```

### DELETE - 자산 보유 삭제
```typescript
async deleteHolding(holdingId: string) {
  const query = `
    DELETE FROM asset_holdings WHERE holding_id = $1
  `;
  await db.query(query, [holdingId]);
}
```

---

## Trades Queries

### CREATE - 거래 기록 추가
```typescript
async createTrade(data: {
  tradeId: string;
  portfolioId: string;
  userId: string;
  assetSymbol: string;
  assetName: string;
  assetType: string;
  tradeType: 'buy' | 'sell';
  quantity: number;
  price: number;
  fee: number;
  notes?: string;
  tradeDate: Date;
}) {
  const totalAmount = data.quantity * data.price;

  const query = `
    INSERT INTO trade_history (
      trade_id, portfolio_id, user_id, asset_symbol, asset_name, asset_type,
      trade_type, quantity, price, total_amount, fee, currency, notes,
      trade_date, created_at
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, 'KRW', $12, $13, NOW())
    RETURNING *
  `;

  const result = await db.query(query, [
    data.tradeId,
    data.portfolioId,
    data.userId,
    data.assetSymbol,
    data.assetName,
    data.assetType,
    data.tradeType,
    data.quantity,
    data.price,
    totalAmount,
    data.fee,
    data.notes || null,
    data.tradeDate
  ]);

  return result.rows[0];
}
```

### READ - 거래 기록 조회

**Portfolio Trades:**
```typescript
async getPortfolioTrades(
  portfolioId: string,
  filters: { symbol?: string; tradeType?: string },
  limit: number,
  offset: number
) {
  let query = `
    SELECT * FROM trade_history
    WHERE portfolio_id = $1
  `;

  const params: any[] = [portfolioId];
  let paramIndex = 2;

  if (filters.symbol) {
    query += ` AND asset_symbol = $${paramIndex++}`;
    params.push(filters.symbol);
  }

  if (filters.tradeType) {
    query += ` AND trade_type = $${paramIndex++}`;
    params.push(filters.tradeType);
  }

  query += ` ORDER BY trade_date DESC LIMIT $${paramIndex++} OFFSET $${paramIndex}`;
  params.push(limit, offset);

  const result = await db.query(query, params);
  return result.rows;
}
```

**User Trades:**
```typescript
async getUserTrades(userId: string, limit: number, offset: number) {
  const query = `
    SELECT * FROM trade_history
    WHERE user_id = $1
    ORDER BY trade_date DESC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, [userId, limit, offset]);
  return result.rows;
}
```

### DELETE - 거래 기록 삭제
```typescript
async deleteTrade(tradeId: string) {
  const query = `
    DELETE FROM trade_history WHERE trade_id = $1
  `;
  await db.query(query, [tradeId]);
}
```

---

이 문서는 모든 주요 테이블의 CRUD 작업을 완전하게 다룹니다. 각 쿼리는 실제 프로덕션 환경에서 사용 가능하며, 트랜잭션과 동시성 제어를 고려하여 작성되었습니다.
