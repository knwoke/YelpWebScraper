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

DATA_URL = ("https://github.com/knwoke/YelpWebScraper/blob/main/KATZReviewFinalJul2005May2023v3.csv")

@st.cache_data(persist=True)
def load_data():
    data = pd.read_csv(DATA_URL, lineterminator='\n')
    data['date'] = pd.to_datetime(data['date'])
    return data

data = load_data()

st.sidebar.subheader("Show random review")
random_review = st.sidebar.radio('Rating', (1, 2, 3, 4, 5))
st.sidebar.markdown(data.query('rating == @random_review')[["comment"]].sample(n=1).iat[0,0])

st.sidebar.markdown("### Number of reviews by rating")
select = st.sidebar.selectbox('Visualization type', ['Histogram', 'Pie chart'], key='1')
rating_count = data['rating'].value_counts()
rating_count = pd.DataFrame({'Rating':rating_count.index, 'Reviews':rating_count.values})

if not st.sidebar.checkbox("Hide", True):
    st.markdown("### Number of reviews by rating")
    if select == "Histogram":
        fig = px.bar(rating_count, x='Rating', y='Reviews', color='Reviews', height=500)
        st.plotly_chart(fig)
    else: 
        fig = px.pie(rating_count, values='Reviews', names='Rating')
        st.plotly_chart(fig)
        
        
st.sidebar.subheader("What month and where are users reviewing from")
month = st.sidebar.slider("Month of year", 1, 12 )
modified_data = data[data['date'].dt.month == month]
if not st.sidebar.checkbox("Close", True, key='2'):
    st.markdown("### Reviews locations based on the month of the year")
    st.markdown("%i reviews between %i and %i" % (len(modified_data), month, (month+1)%12))
    st.map(modified_data)
    if st.sidebar.checkbox("Show raw data", False):
        st.write(modified_data)

st.sidebar.subheader("Breakdown Yelp reviews by New York Borough")
choice = st.sidebar.multiselect('Pick borough', ('Queens', 'Manhattan', 'New York', 'Brooklyn', 'Staten Island', 'Bronx'))

if len(choice) > 0:
    choice_data = data[data.City.isin(choice)]
    fig_choice = px.histogram(choice_data, x='City', y='rating', histfunc='count', color='rating',
    facet_col='rating', labels={'rating': 'rating'}, height=600, width=800)
    st.plotly_chart(fig_choice)
    
st.sidebar.header("Word Cloud")
word_rating = st.sidebar.radio('Display word cloud for what rating?', (1, 2, 3, 4, 5))

if not st.sidebar.checkbox("Close", True, key='3'):
    st.header('Word cloud for %d rating' % (word_rating))
    df = data[data['rating']==word_rating]
    words = ' '.join(df['comment'])
    processed_words = ' '.join([word for word in words.split() if 'http' not in word and not word.startswith('@') and word !='RT'])
    wordcloud = WordCloud(stopwords=STOPWORDS, background_color='white', height=640, width=800).generate(processed_words)
    plt.imshow(wordcloud)
    plt.xticks([])
    plt.yticks([])
    st.pyplot()
    st.set_option('deprecation.showPyplotGlobalUse', False)
    
