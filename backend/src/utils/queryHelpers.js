const buildPagination = (query) => {
  const page = Math.max(parseInt(query.page, 10) || 1, 1);
  const limit = Math.max(Math.min(parseInt(query.limit, 10) || 10, 100), 1);
  const skip = (page - 1) * limit;
  return { page, limit, skip };
};

module.exports = {
  buildPagination,
};
