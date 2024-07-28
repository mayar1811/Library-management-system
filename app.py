from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///library.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Book model
class Book(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    isbn = db.Column(db.String(13), unique=True, nullable=False)
    title = db.Column(db.String(100), nullable=False)
    author = db.Column(db.String(100), nullable=False)
    is_borrowed = db.Column(db.Boolean, default=False)

    def __repr__(self):
        return f'<Book {self.title}>'

# Initialize the database
with app.app_context():
    db.create_all()

# Home route
@app.route('/')
def index():
    books = Book.query.all()
    return render_template('index.html', books=books)

# Add book route
@app.route('/add_book', methods=['GET', 'POST'])
def add_book():
    if request.method == 'POST':
        isbn = request.form['isbn']
        title = request.form['title']
        author = request.form['author']
        new_book = Book(isbn=isbn, title=title, author=author)
        db.session.add(new_book)
        db.session.commit()
        return redirect(url_for('index'))
    return render_template('add_book.html')

# Borrow book route
@app.route('/borrow_book', methods=['GET', 'POST'])
def borrow_book():
    if request.method == 'POST':
        title = request.form['title']
        book = Book.query.filter_by(title=title).first()
        if book and not book.is_borrowed:
            book.is_borrowed = True
            db.session.commit()
        return redirect(url_for('index'))
    return render_template('borrow_book.html')

# Return book route
@app.route('/return_book', methods=['GET', 'POST'])
def return_book():
    if request.method == 'POST':
        title = request.form['title']
        book = Book.query.filter_by(title=title).first()
        if book and book.is_borrowed:
            book.is_borrowed = False
            db.session.commit()
        return redirect(url_for('index'))
    return render_template('return_book.html')

# Search book route
@app.route('/search_book', methods=['GET', 'POST'])
def search_book():
    books = None
    if request.method == 'POST':
        title = request.form.get('title', '')
        books = Book.query.filter(Book.title.ilike(f'%{title}%')).all()
    return render_template('search_book.html', books=books)

# Remove book route
@app.route('/remove_book', methods=['GET', 'POST'])
def remove_book():
    if request.method == 'POST':
        title = request.form['title']
        book = Book.query.filter_by(title=title).first()
        if book:
            db.session.delete(book)
            db.session.commit()
        return redirect(url_for('index'))
    return render_template('remove_book.html')

if __name__ == '__main__':
    app.run(debug=True)

