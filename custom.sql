CREATE USER anon;

COMMIT;

GRANT USAGE ON SCHEMA public TO anon;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT
SELECT
    ON TABLES TO anon;

GRANT
SELECT
    ON ALL SEQUENCES IN SCHEMA public TO anon;

GRANT
SELECT
    ON ALL TABLES IN SCHEMA public TO anon;

CREATE table
    IF NOT EXISTS pets (
        name text NOT NULL
    );

COMMIT;

INSERT INTO
    pets (name)
VALUES
    ('Buddy'),
    ('Lucy'),
    ('Charlie'),
    ('Bobby');

COMMIT;

-- Next, add the text/html as a Media Type Handlers. 
-- With this, PostgREST can identify the request made by your web browser (with the Accept: text/html header)
-- and return a raw HTML document file.
create domain "text/html" as text;

create or replace function public.sanitize_html(text) returns text as $$
  select replace(replace(replace(replace(replace($1, '&', '&amp;'), '"', '&quot;'),'>', '&gt;'),'<', '&lt;'), '''', '&apos;')
$$ language sql;

create or replace function html_pet(pets) returns text as $$
  select format($html$
    <div>
      <%2$s>
        %3$s
      </%2$s>
    </div>
    $html$,
    $1.name,
    'span',
    sanitize_html($1.name)
  );
$$ language sql stable;

create or replace function html_all_pets() returns text as $$
  select coalesce(
    string_agg(html_pet(p), '<hr/>' order by p.name),
    '<p><em>There is no other pet.</em></p>'
  )
  from pets p;
$$ language sql;

create or replace function add_pet(_name text) returns "text/html" as $$
  insert into pets (name) values (_name);
  select html_all_pets();
$$ language sql;

create or replace function index() returns "text/html" as $$
  select $html$
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>PostgREST + HTMX Pet List</title>
      <!-- Pico CSS for CSS styling -->
      <link href="https://cdn.jsdelivr.net/npm/@picocss/pico@next/css/pico.min.css" rel="stylesheet"/>
      <!-- htmx for AJAX requests -->
      <script src="https://unpkg.com/htmx.org"></script>
    </head>
    <body>
      <main class="container"
            style="max-width: 600px"
            hx-headers='{"Accept": "text/html"}'>
        <article>
          <h5 style="text-align: center;">
            PostgREST + HTMX Pets
          </h5>
          <form hx-post="/rpc/add_pet"
                hx-target="#pet-list-area"
                hx-trigger="submit"
                hx-on="htmx:afterRequest: this.reset()">
            <input type="text" name="_name" placeholder="Add a pet...">
          </form>
          <div id="pet-list-area">
            $html$
              || html_all_pets() ||
            $html$
          <div>
        </article>
      </main>
    </body>
    </html>
  $html$;
$$ language sql;

grant execute on function add_pet(text) to anon;
GRANT UPDATE, INSERT, DELETE ON TABLE public.pets TO anon;