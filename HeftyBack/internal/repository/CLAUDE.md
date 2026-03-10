# Repository Layer

## Rules

1. **Interface first.** Define in `interfaces.go` before implementing. All methods take `context.Context` as first param.

2. **Compile-time check.** Every implementation must include:
   ```go
   var _ FooRepositoryInterface = (*FooRepository)(nil)
   ```

3. **User scoping.** ALL queries on user data include `WHERE user_id = $N`. No exceptions.
   ```sql
   -- CORRECT
   SELECT * FROM workout_templates WHERE id = $1 AND user_id = $2

   -- WRONG — security vulnerability
   SELECT * FROM workout_templates WHERE id = $1
   ```

4. **Not found = nil, nil.** Never return an error for missing records.
   ```go
   if errors.Is(err, pgx.ErrNoRows) {
       return nil, nil
   }
   ```

5. **Constructor pattern:**
   ```go
   type FooRepository struct { pool *pgxpool.Pool }
   func NewFooRepository(pool *pgxpool.Pool) *FooRepository {
       return &FooRepository{pool: pool}
   }
   ```

6. **Optional DB fields** use pointers: `*string`, `*int`, `*float64`.

7. **Error propagation.** Return DB errors directly — handlers use `handleDBError()` to convert.

8. **Never import** handler types or middleware. Repository only knows about `pgx` and its own types.
