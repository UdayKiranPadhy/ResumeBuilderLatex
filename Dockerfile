FROM texlive/texlive:latest

WORKDIR /resume

COPY . .

CMD ["make", "all"]
