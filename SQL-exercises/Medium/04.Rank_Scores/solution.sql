SELECT s1.Score, (SELECT COUNT(DISTINCT Score) + 1 FROM Scores WHERE Score > s1.Score) AS Rank
FROM Scores s1
ORDER BY s1.Score DESC