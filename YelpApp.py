import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
from wordcloud import WordCloud, STOPWORDS
import matplotlib.pyplot as plt

st.title("Sentiment Analysis of Katz's Deli Yelp Reviews")
st.sidebar.title("Sentiment Analysis of Yelp Reviews")

st.markdown("This application is a Streamlit dashboard to analyze the sentiment of Yelp reviews 🥪")
st.sidebar.markdown("Streamlit Analysis 🥪")

col_names = ["username", "date", "Month", "Day", "Year", "City NOT TRIM"," State/Foreign Country NOT TRIM", "Coordinates Old", "rating", "numberoffollowers", "numberofreviews", "City", "State", "City State", "Coordinates New", "LAT", "LON", "comment"]

DATA_URL = ("https://github.com/knwoke/YelpWebScraper/blob/main/KATZReviewFinalJul2005May2023v3.csv")

@st.cache_data(persist=True)
def load_data():
    data = pd.read_csv(DATA_URL, names = col_names)
    data['date'] = pd.to_datetime(data['date'])
    return data

data = load_data()

display(data)
